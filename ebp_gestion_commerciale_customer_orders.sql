SELECT 
  SaleDocument.DocumentNumber as NumeroCommande,
  CAST(SaleDocument.DocumentDate AS DATE) AS DateCommande,
  Colleague.Id AS CodeCommercialCommande,
  SaleDocument.CustomerId AS CodeClientCommande,
  Customer.Name AS NomClientCommande,
  CASE CAST(LEFT(Customer.Naf,4) AS INTEGER)
  /* Exemples de tri de code NAF */
  WHEN 1071 THEN 'Boulangerie - Patisserie'
	WHEN 1072 THEN 'Boulangerie - Patisserie'
	WHEN 1032 THEN 'Fruits et Légumes'
	WHEN 1039 THEN 'Fruits et Légumes'
	WHEN 1020 THEN 'Poisson - Marée'
	WHEN 1085 THEN 'Traiteur - Plats préparés'
	WHEN 1089 THEN 'Traiteur - Plats préparés'
	WHEN 1011 THEN 'Viande - Charcuterie'
	WHEN 1013 THEN 'Viande - Charcuterie'
	WHEN 1012 THEN 'Volaille'
	WHEN 1051 THEN 'Laiterie - Fromagerie'
	ELSE 'Autres'
  END AS SecteurClient,
  SaleDocument.DeliveryAddress_City AS VilleLivraisonCommande,
  ClassificationGroup1.Caption AS Groupe1ClientCommande,
  ClassificationGroup2.Caption AS Groupe2ClientCommande,
  SaleDocumentLine.Numbering AS NumeroLigneCommande,
  Item.FamilyId AS CodeFamilleArticleLigneCommande,
  ItemFamily.Caption AS NomFamilleArticleLigneCommande,
  Item.Id AS CodeArticleLigneCommande,
  ClassificationItemGroup2.Caption AS Groupe2Article,
  SaleDocumentLine.Quantity AS QuantiteLigneCommande,
  SaleDocumentLine.RealNetAmountVatExcludedWithDiscount AS MontantNetHTLigneCommande,
  SaleDocumentLine.CostPrice * SaleDocumentLine.Quantity AS PrixRevientLigneCommande,
  SaleDocumentLine.RealNetAmountVatExcludedWithDiscount - (SaleDocumentLine.CostPrice * SaleDocumentLine.Quantity) AS MargeNetteHTLigneCommande
FROM SaleDocument
  Left Outer Join SaleDocumentLine On SaleDocument.Id = SaleDocumentLine.DocumentId AND (SaleDocumentLine.LineType IN('10','11','12','2') Or (SaleDocumentLine.LineType = '3' And SaleDocumentLine.NomenclatureLevel ='0'))
  Left Outer Join Item On SaleDocumentLine.ItemId = Item.Id
  Left Outer Join ItemFamily On Item.FamilyId = ItemFamily.Id
  Left Outer Join Colleague On SaleDocument.ColleagueId = Colleague.Id
  Left Outer Join Customer On SaleDocument.CustomerId = Customer.Id
  Left Outer Join ClassificationGroup ClassificationGroup1 On Customer.Group1 = ClassificationGroup1.Id
  Left Outer Join ClassificationGroup ClassificationGroup2 On Customer.Group2 = ClassificationGroup2.Id
  Left Outer Join ClassificationGroup ClassificationItemGroup2 On Item.Group2 = ClassificationItemGroup2.Id
WHERE 
/* Uniquement les documents de type 'Commande Client' */
SaleDocument.DocumentType = 8
/* Uniquement les documents de l'année N-1 et N */
AND SaleDocument.DocumentDate > CAST(DATEADD(yy, DATEDIFF(yy, 0, GETDATE() ) - 1, 0) AS DATE)
/* On ignore les commande Divers saisies à la main pour lesquelles le coût n'est pas renseigné */
AND SaleDocumentLine.CostPrice * SaleDocumentLine.Quantity <> 0 
/* On ignore les échantillons pour lequel le prix net n'est pas renseigné */
AND SaleDocumentLine.RealNetAmountVatExcludedWithDiscount <> 0