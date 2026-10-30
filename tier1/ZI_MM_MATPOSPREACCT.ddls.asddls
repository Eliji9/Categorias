//---------------------------------------------------------------------
// TIER 1 (ABAP Cloud)
// Base del reporte: material + área de valoración + CUENTA DE MAYOR
// determinada según el tipo de material.
//
// Materiales de activo fijo (ProductType = 'RACF'):
//   MBEW-BKLAS + KTOPL -> ZTCLASE_AF (ANLKL)
//                      -> ANKA (KTOGR)
//                      -> T095 (KTOPL, KTOGR, AFABE = '01') -> KTANSW (Cta. CAP)
//
// Resto de materiales:
//   MBEW-BKLAS -> T030 (KTOSL = 'GBB', KOMOK, BWMOD) -> KONTS
//
// El plan de cuentas sale de la sociedad del área de valoración
// (T001K -> T001-KTOPL). La cuenta resultante (GLAccount) es la que
// usa ZR_MM_MatPospre para Pospre (SKB1), textos y Cuenta AS400.
//---------------------------------------------------------------------
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Material - Pospre: determinación de cuenta'
@ObjectModel.usageType: {
  serviceQuality: #C,
  sizeCategory:   #L,
  dataClass:      #MIXED
}
define view entity ZI_MM_MatPospreAcct
  // MBEW
  as select from    I_ProductValuationBasic    as Valuation

  // MARA
    inner join      I_Product                  as Product
      on Product.Product = Valuation.Product

  // T001K
    left outer join ZI_MM_ValAreaGrp_T2        as ValArea
      on ValArea.ValuationArea = Valuation.ValuationArea

  // T001
    left outer join I_CompanyCode              as CompanyCode
      on CompanyCode.CompanyCode = ValArea.CompanyCode

  // ---------------- Materiales de inventario: T030 - GBB ----------------
    left outer join ZI_FI_AutoAcctDet_T2       as AcctDet
      on  AcctDet.ChartOfAccounts       = CompanyCode.ChartOfAccounts
      and AcctDet.TransactionKey        = 'GBB'
      and AcctDet.AccountModifier       = 'VBR' // TODO: reemplazar por el valor de c_komok del reporte original
      and AcctDet.ValuationGroupingCode = ValArea.ValuationGroupingCode
      and AcctDet.ValuationClass        = Valuation.ValuationClass

  // ---------------- Materiales de activo fijo (RACF) ----------------
  // ZTCLASE_AF: categoría de valoración -> clase de activo fijo
    left outer join ZI_FI_AssetClassByValCl_T2 as AssetClassMap
      on  AssetClassMap.ValuationClass  = Valuation.ValuationClass
      and AssetClassMap.ChartOfAccounts = CompanyCode.ChartOfAccounts

  // ANKA: clase de activo fijo -> determinación de cuentas
    left outer join ZI_FI_AssetClassAcctDet_T2 as AssetClass
      on AssetClass.AssetClass = AssetClassMap.AssetClass

  // T095: plan + determinación + área 01 -> cuenta CAP
    left outer join ZI_FI_AssetGLAccount_T2    as AssetAcct
      on  AssetAcct.ChartOfAccounts           = CompanyCode.ChartOfAccounts
      and AssetAcct.AssetAccountDetermination = AssetClass.AssetAccountDetermination
      and AssetAcct.AssetDepreciationArea     = '01'
{
  key Valuation.Product                       as Product,
  key Valuation.ValuationArea                 as ValuationArea,
      Valuation.ValuationClass                as ValuationClass,
      Product.ProductType                     as ProductType,
      Product.ProductGroup                    as ProductGroup,
      ValArea.CompanyCode                     as CompanyCode,
      CompanyCode.ChartOfAccounts             as ChartOfAccounts,
      CompanyCode.FinancialManagementArea     as FinancialManagementArea,

      // Cuenta de mayor según tipo de material
      case Product.ProductType
        when 'RACF' then AssetAcct.AcquisitionCostAccount
        else             AcctDet.GLAccount
      end                                     as GLAccount,

      // Trazabilidad de la determinación de activo fijo (solo RACF)
      case Product.ProductType
        when 'RACF' then AssetClassMap.AssetClass
        else             cast( '' as abap.char( 8 ) )
      end                                     as AssetClass,

      case Product.ProductType
        when 'RACF' then AssetClass.AssetAccountDetermination
        else             cast( '' as abap.char( 8 ) )
      end                                     as AssetAccountDetermination
}
// Solo registro de cabecera de valoración (sin valoración separada / BWTAR)
where
  Valuation.ValuationType = ''
