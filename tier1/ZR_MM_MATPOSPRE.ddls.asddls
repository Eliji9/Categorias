//---------------------------------------------------------------------
// TIER 1 (ABAP Cloud) - Vista raíz RAP (solo lectura)
// Reemplaza: ZMM_CONS_MAT_POSPRE2 (FORM f_get_data + f_fill_data)
//
// Cadena de determinación (igual al reporte original):
//   MBEW -> T001K (BUKRS, BWMOD) -> T001 (KTOPL)
//        -> T030 (KTOSL = 'GBB', KOMOK, BWMOD, BKLAS) -> KONTS
//        -> SKB1 (FIPOS) -> FMCIT (texto Pospre)
//        -> SKAT / SKA1 / T077Z (textos cuenta y grupo)
//        -> ZTCTAS_REGULAT (Cuenta AS400 = Cuenta regulatoria)
//
// Todas las uniones son LEFT OUTER (como el LOOP original, que
// agregaba la fila aunque no encontrara cuenta).
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
  // MBEW
  as select from    I_ProductValuationBasic      as Valuation

  // MARA
    inner join      I_Product                    as Product
      on Product.Product = Valuation.Product

  // MAKT
    left outer join I_ProductDescription         as ProductText
      on  ProductText.Product  = Valuation.Product
      and ProductText.Language = $session.system_language

  // MARC (marca de borrado a nivel centro; área de valoración = centro)
    left outer join I_ProductPlantBasic          as ProductPlant
      on  ProductPlant.Product = Valuation.Product
      and ProductPlant.Plant   = Valuation.ValuationArea

  // T134T
    left outer join I_ProductTypeText_2          as ProductTypeText
      on  ProductTypeText.ProductType = Product.ProductType
      and ProductTypeText.Language    = $session.system_language

  // T023T (WGBEZ60)
    left outer join I_ProductGroupText_2         as ProductGroupText
      on  ProductGroupText.ProductGroup = Product.ProductGroup
      and ProductGroupText.Language     = $session.system_language

  // T001K
    left outer join ZI_MM_ValAreaGrp_T2          as ValArea
      on ValArea.ValuationArea = Valuation.ValuationArea

  // T001
    left outer join I_CompanyCode                as CompanyCode
      on CompanyCode.CompanyCode = ValArea.CompanyCode

  // T030 - Operación GBB
    left outer join ZI_FI_AutoAcctDet_T2         as AcctDet
      on  AcctDet.ChartOfAccounts       = CompanyCode.ChartOfAccounts
      and AcctDet.TransactionKey        = 'GBB'
      and AcctDet.AccountModifier       = 'VBR' // TODO: reemplazar por el valor de c_komok del reporte original
      and AcctDet.ValuationGroupingCode = ValArea.ValuationGroupingCode
      and AcctDet.ValuationClass        = Valuation.ValuationClass

  // SKB1 (Pospre)
    left outer join ZI_FI_GLAcctCmmtItem_T2      as GLAcctCoCode
      on  GLAcctCoCode.CompanyCode = ValArea.CompanyCode
      and GLAcctCoCode.GLAccount   = AcctDet.GLAccount

  // FMCIT
    left outer join ZI_PSM_CmmtItemTextCur       as CmmtItemText
      on  CmmtItemText.FinancialManagementArea = CompanyCode.FinancialManagementArea
      and CmmtItemText.CommitmentItem          = GLAcctCoCode.CommitmentItem
      and CmmtItemText.Language                = $session.system_language

  // SKA1 (grupo de cuentas)
    left outer join I_GLAccountInChartOfAccounts as GLAcctCoA
      on  GLAcctCoA.ChartOfAccounts = CompanyCode.ChartOfAccounts
      and GLAcctCoA.GLAccount       = AcctDet.GLAccount

  // SKAT (TXT50)
    left outer join I_GLAccountText              as GLAcctText
      on  GLAcctText.ChartOfAccounts = CompanyCode.ChartOfAccounts
      and GLAcctText.GLAccount       = AcctDet.GLAccount
      and GLAcctText.Language        = $session.system_language

  // T077Z (TXT30)
    left outer join I_GLAccountGroupText         as GLAcctGroupText
      on  GLAcctGroupText.ChartOfAccounts = GLAcctCoA.ChartOfAccounts
      and GLAcctGroupText.GLAccountGroup  = GLAcctCoA.GLAccountGroup
      and GLAcctGroupText.Language        = $session.system_language

  // ZTCTAS_REGULAT (Cuenta AS400)
    left outer join ZI_FI_CtasRegulat_T2         as RegAccount
      on  RegAccount.GLAccount       = AcctDet.GLAccount
      and RegAccount.ChartOfAccounts = CompanyCode.ChartOfAccounts
      and RegAccount.CompanyCode     = ValArea.CompanyCode
{
  key Valuation.Product                  as Product,
  key Valuation.ValuationArea            as ValuationArea,
      ProductText.ProductDescription     as ProductDescription,
      Valuation.ValuationClass           as ValuationClass,
      GLAcctCoCode.CommitmentItem        as CommitmentItem,
      CmmtItemText.CommitmentItemName    as CommitmentItemName,
      AcctDet.GLAccount                  as GLAccount,
      ProductPlant.IsMarkedForDeletion   as IsMarkedForDeletionAtPlant,
      Product.ProductType                as ProductType,
      ProductTypeText.ProductTypeName    as ProductTypeName,
      Product.ProductGroup               as ProductGroup,
      ProductGroupText.ProductGroupText  as ProductGroupText,
      GLAcctText.GLAccountLongName       as GLAccountLongName,
      GLAcctGroupText.AccountGroupName   as GLAccountGroupName,
      RegAccount.RegulatoryAccount       as AS400Account,

      // Técnicos (ocultos en UI, necesarios para value help / trazabilidad)
      ValArea.CompanyCode                as CompanyCode,
      CompanyCode.ChartOfAccounts        as ChartOfAccounts
}
// Solo registro de cabecera de valoración (sin valoración separada / BWTAR)
where
  Valuation.ValuationType = ''
