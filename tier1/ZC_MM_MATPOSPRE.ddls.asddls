//---------------------------------------------------------------------
// TIER 1 (ABAP Cloud) - Proyección de consumo (UI)
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte Material - Pospre'
@Metadata.allowExtensions: true
@Search.searchable: true
@ObjectModel.semanticKey: [ 'Product', 'ValuationArea' ]
define root view entity ZC_MM_MatPospre
  provider contract transactional_query
  as projection on ZR_MM_MatPospre
{
      @EndUserText.label: 'Material'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductStdVH', element: 'Product' } }]
  key Product,

      @EndUserText.label: 'Centro / Área val.'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH', element: 'Plant' } }]
  key ValuationArea,

      @EndUserText.label: 'Texto breve material'
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      ProductDescription,

      @EndUserText.label: 'Cat. valoración'
      ValuationClass,

      @EndUserText.label: 'Pospre'
      CommitmentItem,

      @EndUserText.label: 'Descripción Pospre'
      CommitmentItemName,

      @EndUserText.label: 'Cuenta mayor'
      @Consumption.valueHelpDefinition: [{
        entity:            { name: 'I_GLAccountStdVH', element: 'GLAccount' },
        additionalBinding: [{ localElement: 'CompanyCode', element: 'CompanyCode', usage: #FILTER_AND_RESULT }]
      }]
      GLAccount,

      @EndUserText.label: 'Niv. centro (marca borrado)'
      IsMarkedForDeletionAtPlant,

      @EndUserText.label: 'Tipo de material'
      ProductType,

      @EndUserText.label: 'Denom. tipo mat.'
      ProductTypeName,

      @EndUserText.label: 'Grupo art.'
      ProductGroup,

      @EndUserText.label: 'Denom. gr. artículos 2'
      ProductGroupText,

      @EndUserText.label: 'Texto cuenta'
      GLAccountLongName,

      @EndUserText.label: 'Texto grupo cuenta'
      GLAccountGroupName,

      @EndUserText.label: 'Cuenta AS400'
      AS400Account,

      @EndUserText.label: 'Clase activo fijo'
      AssetClass,

      @EndUserText.label: 'Determ. cuentas AF'
      AssetAccountDetermination,

      @EndUserText.label: 'Sociedad'
      CompanyCode,

      @EndUserText.label: 'Plan de cuentas'
      ChartOfAccounts
}
