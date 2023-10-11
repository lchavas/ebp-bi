SELECT 
  Account.AccountNumber as CompteClient,
  CAST (EntryLine.EntryLineDate AS DATE) as DateEcriture,
  CONVERT(nchar(10),EntryLine.EntryLineDate, 111) as DateEcritureAffichable,
  JournalTotals.JournalCode as CodeJournalEcriture,
  CONCAT(CAST(EntryLine.EntryNumber As VARCHAR(100)),'-',CAST(EntryLine.IndexInEntry As int)) AS NumeroEcriture,  
  CONCAT(CAST(EcritureOrigine.EntryNumber As VARCHAR(100)),'-',CAST(EcritureOrigine.IndexInEntry As int)) AS NumeroEcritureOrigine,
  EntryLine.DocumentNumber as CodeDocument,
  Account.FullName as RaisonSociale,
  EntryLine.Label as LibelleEcriture,
  EntryLine.VoucherNumber as NumeroPieceEcriture,
  (EntryLine.Debit - EntryLine.Credit) AS BalanceEcriture,
  CASE EntryLine.IsExternallyPointed
    WHEN 0 THEN 'Non Pointée'
    WHEN 1 THEN 'Pointée'
  END AS Pointage,
  CASE Entryline.ApplyingType
    WHEN 0 THEN 'Non Lettrée'
    WHEN 1 THEN 'Lettrée'
	WHEN 3 THEN 'Lettrée Partiellement'
  END AS Lettrage,
  Entryline.ApplyingCode AS CodeLettrage,
  CAST (Entryline.ApplyingDate AS date) AS DateLettrage,
  CAST(Commitment.LastReminderDate AS DATE) as DateDerniereRelance,
  ISNULL(Commitment.NbReminders, 0 ) as NombreRelances,
  CAST (Commitment.DueLineDate AS DATE) as DateEcheance,
  CONVERT(nchar(10),Commitment.DueLineDate, 111) as DateEcheanceAffichable,
  CASE Commitment.DueLineType
    WHEN 0 THEN 'Facture'
    WHEN 1 THEN 'Avoir'
  END AS TypeEcheance,
  DATEPART(qq,Commitment.DueLineDate) as QuarterEcheance,
  DATEPART(ISO_WEEK,Commitment.DueLineDate) as SemaineEcheance,
  DATEDIFF(dd, GETDATE(), Commitment.DueLineDate) AS joursRestantAvantEcheance,
  /* Now the amounts commited in increments of 30 days */
  CASE WHEN Commitment.DueLineDate IS NULL THEN (EntryLine.Debit - EntryLine.Credit) ELSE 0 END AS MontantSansEcheance,
  CASE WHEN DATEDIFF(dd, GETDATE(), Commitment.DueLineDate) < -90 THEN (EntryLine.Debit - EntryLine.Credit) ELSE 0 END AS MontantEchuPlus90Jours,
  CASE WHEN DATEDIFF(dd, GETDATE(), Commitment.DueLineDate) BETWEEN -90 AND -61 THEN (EntryLine.Debit - EntryLine.Credit) ELSE 0 END AS MontantEchu90Jours,
  CASE WHEN DATEDIFF(dd, GETDATE(), Commitment.DueLineDate) BETWEEN -60 AND -31 THEN (EntryLine.Debit - EntryLine.Credit) ELSE 0 END AS MontantEchu60Jours,
  CASE WHEN DATEDIFF(dd, GETDATE(), Commitment.DueLineDate) BETWEEN -30 AND -1 THEN (EntryLine.Debit - EntryLine.Credit) ELSE 0 END AS MontantEchu30Jours,
  CASE WHEN DATEDIFF(dd, GETDATE(), Commitment.DueLineDate) BETWEEN 0 AND 30 THEN (EntryLine.Debit - EntryLine.Credit) ELSE 0 END AS MontantAEchoir30Jours,
  CASE WHEN DATEDIFF(dd, GETDATE(), Commitment.DueLineDate) BETWEEN 31 AND 60 THEN (EntryLine.Debit - EntryLine.Credit) ELSE 0 END AS MontantAEchoir60Jours,
  CASE WHEN DATEDIFF(dd, GETDATE(), Commitment.DueLineDate) BETWEEN 61 AND 90 THEN (EntryLine.Debit - EntryLine.Credit) ELSE 0 END AS MontantAEchoir90Jours,
  CASE WHEN DATEDIFF(dd, GETDATE(), Commitment.DueLineDate) > 90 THEN (EntryLine.Debit - EntryLine.Credit) ELSE 0 END AS MontantAEchoirPlus90Jours,
  Commitment.Amount as MontantEcheance,
  Commitment.ChargedAmount as MontantPayeEcheance,
  Commitment.Solde as SoldeEcheance,
  Commitment.PaymentTypeId as ModeReglementEcheance
FROM EntryLine
  Left Outer Join Account On EntryLine.GeneralAccountNumber = Account.AccountNumber
  Left Outer Join Commitment On EntryLine.Id = Commitment.EntryLineId
  Left Outer Join EntryLine EcritureOrigine On EntryLine.OpeningInitialLineId = EcritureOrigine.Id
  /*Left Outer Join CommitmentMatching On Commitment.Id = CommitmentMatching.CommitmentId*/
  /*Left Outer Join Journal On JournalTotals.JournalCode = Journal.Code*/
  Left Outer Join JournalTotals On JournalTotals.NumberId = EntryLine.JournalTotalsNumber
  /*Left Outer Join Settlement On EntryLine.SettlementId = Settlement.Id*/
  /*Left Outer Join PaymentType On EntryLine.PaymentTypeId = PaymentType.Id*/
  /*Left Outer Join AuxAccount On EntryLine.AuxiliaryAccountNumber = AuxAccount.AccountNumber */
WHERE 
/* Calcul du 1er Avril avant et du 31 Mars après la date spécifiée afin de ne considérer que les écritures de l'exercice comptable */
EntryLine.EntryLineDate BETWEEN CAST(CASE WHEN DATEPART(MONTH, GETDATE()) < 4 THEN CONCAT(DATEPART(YEAR, DATEADD(YY,-1,GETDATE())),'0401') ELSE CONCAT(DATEPART(YEAR, GETDATE()),'0401') END AS DATE) AND CAST(GETDATE() AS DATE)
/* Ecritures Lettrées ou Non Lettrées, mais pas lettrées partiellement */
AND Entryline.ApplyingType IN (0,1)
AND (/* Ecriture pas encore lettrée */ Entryline.ApplyingDate IS NULL 
	 /* Ecriture qui sera lettrée dans le futur  */
	 OR Entryline.ApplyingDate > GETDATE())
AND SUBSTRING(Account.AccountNumber,1,3) = '411'