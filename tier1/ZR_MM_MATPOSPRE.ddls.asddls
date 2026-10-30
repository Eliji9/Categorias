//---------------------------------------------------------------------
// TIER 1 (ABAP Cloud) - Vista raíz RAP (solo lectura)
// Reemplaza: ZMM_CONS_MAT_POSPRE2 (FORM f_get_data + f_fill_data)
//
// La cuenta de mayor ya viene determinada desde ZI_MM_MatPospreAcct:
//   - RACF (activo fijo): ZTCLASE_AF -> ANKA -> T095 (Cta. CAP)
//   - Resto:              T030 (GBB)
// Con esa cuenta se resuelven, para ambos casos:
//   - Pospre          : SKB1 (sociedad + cuenta) -> FIPOS
//   - Texto Pospre    : FMCIT (último ejercicio)
//   - Textos cuenta   : SKAT / SKA1 / T077Z
//   - Cuenta AS400    : ZTCTAS_REGULAT (cuenta + plan + sociedad) -> CTAREG
//
// Todas las uniones son LEFT OUTER (la fila sale aunque no haya cuenta).
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte Material - Pospre'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType: {
  serviceQuality: #C,
  sizeCategory:   #L,
  dataClass:      #MIXED
}
define root view entity ZR_MM_MatPospre
  as select from    ZI_MM_MatPospreAcct          as Base

  // MAKT
    left outer join I_ProductDescription         as ProductText
      on  ProductText.Product  = Base.Product
      and ProductText.Language = $session.system_language

  // MARC (marca de borrado a nivel centro)
    left outer join I_ProductPlantBasic          as ProductPlant
      on  ProductPlant.Product = Base.Product
      and ProductPlant.Plant   = Base.ValuationArea

  // T134T
    left outer join I_ProductTypeText_2          as ProductTypeText
      on  ProductTypeText.ProductType = Base.ProductType
      and ProductTypeText.Language    = $session.system_language

  // T023T (WGBEZ60)
    left outer join I_ProductGroupText_2         as ProductGroupText
      on  ProductGroupText.ProductGroup = Base.ProductGroup
      and ProductGroupText.Language     = $session.system_language

  // SKB1 (Pospre)
    left outer join ZI_FI_GLAcctCmmtItem_T2      as GLAcctCoCode
      on  GLAcctCoCode.CompanyCode = Base.CompanyCode
      and GLAcctCoCode.GLAccount   = Base.GLAccount

  // FMCIT
    left outer join ZI_PSM_CmmtItemTextCur       as CmmtItemText
      on  CmmtItemText.FinancialManagementArea = Base.FinancialManagementArea
      and CmmtItemText.CommitmentItem          = GLAcctCoCode.CommitmentItem
      and CmmtItemText.Language                = $session.system_language

  // SKA1 (grupo de cuentas)
    left outer join I_GLAccountInChartOfAccounts as GLAcctCoA
      on  GLAcctCoA.ChartOfAccounts = Base.ChartOfAccounts
      and GLAcctCoA.GLAccount       = Base.GLAccount

  // SKAT (TXT50)
    left outer join I_GLAccountText              as GLAcctText
      on  GLAcctText.ChartOfAccounts = Base.ChartOfAccounts
      and GLAcctText.GLAccount       = Base.GLAccount
      and GLAcctText.Language        = $session.system_language

  // T077Z (TXT30)
    left outer join I_GLAccountGroupText         as GLAcctGroupText
      on  GLAcctGroupText.ChartOfAccounts = GLAcctCoA.ChartOfAccounts
      and GLAcctGroupText.GLAccountGroup  = GLAcctCoA.GLAccountGroup
      and GLAcctGroupText.Language        = $session.system_language

  // ZTCTAS_REGULAT (Cuenta AS400)
    left outer join ZI_FI_CtasRegulat_T2         as RegAccount
      on  RegAccount.GLAccount       = Base.GLAccount
      and RegAccount.ChartOfAccounts = Base.ChartOfAccounts
      and RegAccount.CompanyCode     = Base.CompanyCode
{
  key Base.Product                       as Product,
  key Base.ValuationArea                 as ValuationArea,
      ProductText.ProductDescription     as ProductDescription,
      Base.ValuationClass                as ValuationClass,

      // Cast sin conversion exit: OData V4 no soporta la exit FMCIS (FIPOS)
      cast( GLAcctCoCode.CommitmentItem as abap.char( 24 ) ) as CommitmentItem,

      CmmtItemText.CommitmentItemName    as CommitmentItemName,
      Base.GLAccount                     as GLAccount,
      ProductPlant.IsMarkedForDeletion   as IsMarkedForDeletionAtPlant,
      Base.ProductType                   as ProductType,
      ProductTypeText.ProductTypeName    as ProductTypeName,
      Base.ProductGroup                  as ProductGroup,
      ProductGroupText.ProductGroupText  as ProductGroupText,
      GLAcctText.GLAccountLongName       as GLAccountLongName,
      GLAcctGroupText.AccountGroupName   as GLAccountGroupName,
      RegAccount.RegulatoryAccount       as AS400Account,

      // Activo fijo (solo materiales RACF)
      Base.AssetClass                    as AssetClass,
      Base.AssetAccountDetermination     as AssetAccountDetermination,

      // Técnicos (ocultos en la tabla, visibles en el detalle)
      Base.CompanyCode                   as CompanyCode,
      Base.ChartOfAccounts               as ChartOfAccounts
}
