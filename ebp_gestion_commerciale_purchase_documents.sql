SELECT 
  PurchaseDocument.DocumentNumber as NumeroCommandeFournisseur,
  CASE PurchaseDocument.DocumentType
    WHEN 2 then 'Facture achat'
    WHEN 3 then 'Avoir fournisseur'
    WHEN 6 then 'Bon de réception'
    WHEN 7 then 'Bon de retour'
    WHEN 8 then 'Commande Fournisseur' 
  END AS TypeDocument,
  CAST(PurchaseDocument.DocumentDate AS DATE) AS DateCommandeFournisseur,
  PurchaseDocument.ColleagueId AS CodeCommercialCommandeFournisseur,
  Colleague.Contact_FirstName AS PrenomCommercialCommandeFournisseur,
  Colleague.Contact_Name AS NomCommercialCommandeFournisseur,
  PurchaseDocument.SupplierId AS CodeFournisseur,
  Supplier.Name AS NomFournisseur,
  PurchaseDocumentLine.Numbering AS NumeroLigneCommandeFournisseur,
  Item.FamilyId AS CodeFamilleArticleLigneCommandeFournisseur,
  ItemFamily.Caption AS NomFamilleArticleLigneCommandeFournisseur,
  Item.Id AS CodeArticleLigneCommandeFournisseur,
  PurchaseDocumentLine.Quantity AS QuantiteLigneCommandeFournisseur,
  PurchaseDocumentLine.RealNetAmountVatExcludedWithDiscount AS PrixNetHTLigneCommandeFournisseur
FROM PurchaseDocument
  Left Outer Join Supplier On PurchaseDocument.SupplierId = Supplier.Id
  Left Outer Join (Select PurchaseDocumentLine.* From PurchaseDocumentLine Where (PurchaseDocumentLine.LineType = '10') Or (PurchaseDocumentLine.LineType = '11') Or (PurchaseDocumentLine.LineType = '12') Or (PurchaseDocumentLine.LineType = '2') Or (PurchaseDocumentLine.LineType = '3' And PurchaseDocumentLine.NomenclatureLevel ='0')) PurchaseDocumentLine On PurchaseDocument.Id = PurchaseDocumentLine.DocumentId
  Left Outer Join Item On PurchaseDocumentLine.ItemId = Item.Id
  Left Outer Join ItemFamily On Item.FamilyId = ItemFamily.Id
  Left Outer Join Colleague On PurchaseDocument.ColleagueId = Colleague.Id
WHERE 
/* Uniquement les documents de l'année N-1 et N */
 PurchaseDocument.DocumentDate > CAST(DATEADD(yy, DATEDIFF(yy, 0, GETDATE() ) - 1, 0) AS DATE)