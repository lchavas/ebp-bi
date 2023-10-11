SELECT 
  CAST(Opportunity.OpportunityDate AS date) AS DateOpportunite,
  DATEPART(iso_week, Opportunity.OpportunityDate) AS SemaineOpportunite,
  CAST(Opportunity.OpportunityCloseDate AS date) AS DateClotureOpportunite,
  DATEPART(iso_week, Opportunity.OpportunityCloseDate) AS SemaineClotureOpportunite,
  Opportunity.Id As CodeOpportunite,
  Opportunity.Name As NomOpportunite,
  Opportunity.CustomerAccountId As CodeClientOpportunite,
  CustomerAccount.Name As NomClientOpportunite,
  Colleague.Id AS CodeCommercialOpportunite,
  Colleague.Contact_FirstName AS PrenomCommercialOpportunite,
  Colleague.Contact_Name AS NomCommercialOpportunite,
  Opportunity.NotesClear As NotesOpportunite,
  Opportunity.StageProbability AS PourcentageProbabiliteOpportunite,
  OpportunityStage.Caption AS EtapeEnCoursOpportunite,
  Opportunity.EstimatedAmount AS MontantEstimeOpportunite,
  Opportunity.BalancedAmount AS MontantEstimePondereOpportunite,
  Opportunity.RealizedAmount AS MontantRealiseOpportunite,
  Activity.Id AS CodeActiviteOpportunite,
  Activity.sysCreatedDate AS DateCreation,
  DATEPART(iso_week, Activity.sysCreatedDate) AS SemaineCreationActiviteOpportunite,
  Activity.BeginDate AS DateDebutActiviteOpportunite,
  DATEPART(iso_week, Activity.BeginDate) AS SemaineDebutActiviteOpportunite,
  Activity.EndDate AS DateFinActiviteOpportunite,
  DATEPART(iso_week, Activity.EndDate) AS SemaineFinActiviteOpportunite,
  CASE WHEN Activity.Type = 0 then 'Mail'
    WHEN Activity.Type = 1 then 'Evenement'
    WHEN Activity.Type = 2 then 'Tache'
    WHEN Activity.Type = 3 then 'Appel'
    WHEN Activity.Type = 4 then 'Fax'
    WHEN Activity.Type = 5 then 'Courrier'
    WHEN Activity.Type = 6 then 'SMS' 
	END AS TypeActiviteOpportunite,
  CASE WHEN Activity.Status = 0 then 'Non demarre'
    WHEN Activity.Status = 2 then 'Termine'
	END AS StatutActiviteOpportunite,
  Activity.ColleagueId AS CodeCommercialActiviteOpportunite,
  Activity.EntryColleagueId AS CodeCommercialAyantSaisiActiviteOpportunite,
  Activity.Subject AS SujetActiviteOpportunite,
  Activity.NotesClear as NotesActiviteOpportunite
From Opportunity
  Left Outer Join CustomerAccount On Opportunity.CustomerAccountId = CustomerAccount.Id
  Left Outer Join Colleague On Opportunity.ColleagueId = Colleague.Id
  Left Outer Join OpportunityStage On Opportunity.StageId = OpportunityStage.Id
  Left Outer Join Activity On Activity.OpportunityId = Opportunity.Id
WHERE Opportunity.OpportunityDate > CAST(DATEADD(yy, DATEDIFF(yy, 0, GETDATE() ) - 1, 0) AS DATE)
