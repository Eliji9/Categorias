# ZMM_CONS_MAT_POSPRE2 → RAP / ABAP Cloud (S/4HANA Cloud Private Edition)

## 1. Arquitectura

| Capa | Objeto | Tipo |
|---|---|---|
| Tier 2 (Standard ABAP, liberado C1) | ZI_MM_ValAreaGrp_T2 | CDS View Entity sobre T001K |
| Tier 2 | ZI_FI_AutoAcctDet_T2 | CDS View Entity sobre T030 |
| Tier 2 | ZI_FI_GLAcctCmmtItem_T2 | CDS View Entity sobre SKB1 (FIPOS) |
| Tier 2 | ZI_PSM_CmmtItemText_T2 | CDS View Entity sobre FMCIT |
| Tier 2 | ZI_FI_CtasRegulat_T2 | CDS View Entity sobre ZTCTAS_REGULAT |
| Tier 1 (ABAP Cloud) | ZI_PSM_CmmtItemLastYr | Agregación (último ejercicio Pospre) |
| Tier 1 | ZI_PSM_CmmtItemTextCur | Texto vigente Pospre |
| Tier 1 | ZR_MM_MatPospre | Vista raíz RAP (solo lectura) |
| Tier 1 | ZC_MM_MatPospre (+ DDLX) | Proyección transactional_query + UI |
| Tier 1 | ZSD_MM_MAT_POSPRE | Service Definition |
| Tier 1 | ZSB_MM_MAT_POSPRE_O4 | Service Binding OData V4 – UI (se crea en ADT) |
| App | Fiori Elements V4 List Report + Object Page | BAS (ver manifest_snippet.json) |

Al ser un reporte de solo lectura, no se requiere Behavior Definition: la proyección con
`provider contract transactional_query` expone la consulta y el Object Page funciona con el READ
por clave que resuelve el framework (no aplica el problema del custom entity unmanaged).

Para tablas, el patrón Tier 2 recomendado por SAP es una vista CDS liberada con C1
"Use in Cloud Development". El estándar wrapper interfaz + factory aplica a APIs/FMs; aquí no es necesario.

## 2. Mapeo de tablas clásicas → vistas

| Original | Nuevo | Campos usados |
|---|---|---|
| MBEW | I_ProductValuationBasic | Product, ValuationArea, ValuationClass, ValuationType |
| MARA | I_Product | ProductType, ProductGroup |
| MAKT | I_ProductDescription | ProductDescription |
| MARC | I_ProductPlantBasic | IsMarkedForDeletion |
| T134T | I_ProductTypeText_2 | ProductTypeName |
| T023T | I_ProductGroupText_2 | ProductGroupText (WGBEZ60) |
| T001K | ZI_MM_ValAreaGrp_T2 | CompanyCode, ValuationGroupingCode |
| T001 | I_CompanyCode | ChartOfAccounts, FinancialManagementArea |
| T030 | ZI_FI_AutoAcctDet_T2 | GLAccount (KONTS) – filtro KTOSL = 'GBB' |
| SKB1 | ZI_FI_GLAcctCmmtItem_T2 | CommitmentItem (FIPOS) |
| FMCIT | ZI_PSM_CmmtItemText_T2 → ZI_PSM_CmmtItemTextCur | CommitmentItemName (TEXT1) |
| SKA1 | I_GLAccountInChartOfAccounts | GLAccountGroup |
| SKAT | I_GLAccountText | GLAccountLongName (TXT50) |
| T077Z | I_GLAccountGroupText | AccountGroupName (TXT30) |
| SKB1-ALTKT+TOGRU | ZI_FI_CtasRegulat_T2 | RegulatoryAccount (CTAREG) = Cuenta AS400 |

## 3. Filtros y columnas

Filtros (mismo orden que la pantalla de selección): Material, Centro/Área val., Cat. valoración,
Pospre, Cuenta mayor, Tipo de material.

Columnas: Material, Texto breve material, Área val., Cat. valor., Pos. pres., Descripción,
Cta. mayor, Niv. centro, TpMat, Denom. tipo mat., Grupo art., Denom. gr. artículos 2,
Texto cuenta, Texto grupo cuenta, Cuenta AS400. **"Última modif." eliminada.**

"Debe colocar al menos un criterio de búsqueda" → `initialLoad: Disabled` en el manifest
(no consulta hasta presionar Ir). Si negocio exige obligatoriedad estricta, se puede marcar un
filtro como `@Consumption.filter.mandatory: true`.

## 4. Errores del reporte original que quedan corregidos

1. Si se llenaba Tipo de material, el filtro de Material (so_matnr) se ignoraba.
2. MARC se leía solo por MATNR (sin WERKS): "Niv. centro" salía de un centro cualquiera.
3. T023T se leía sin SPRAS.
4. FMCIT se leía sin FIKRS ni GJAHR (texto de Pospre arbitrario).
5. BWMOD se derivaba por país (CR→Z001 … GT→Z006) en vez de T001K-BWMOD, que es lo que usa la
   determinación real de cuentas. Ahora se toma de T001K.
6. KTOPL era constante; ahora sale del plan de cuentas de la sociedad (I_CompanyCode).
7. El ALV ordenaba por BANFN/BNFPO, columnas inexistentes (código copiado). Ahora ordena por Material / Área val.
8. Se elimina SELECT * / FOR ALL ENTRIES / READ TABLE secuenciales: todo se resuelve en HANA con un solo SELECT.

## 5. Orden de creación

| # | Objeto | Paquete | Depende de |
|---|---|---|---|
| 1 | ZI_MM_VALAREAGRP_T2 | Standard ABAP | T001K |
| 2 | ZI_FI_AUTOACCTDET_T2 | Standard ABAP | T030 |
| 3 | ZI_FI_GLACCTCMMTITEM_T2 | Standard ABAP | SKB1 |
| 4 | ZI_PSM_CMMTITEMTEXT_T2 | Standard ABAP | FMCIT |
| 5 | ZI_FI_CTASREGULAT_T2 | Standard ABAP | ZTCTAS_REGULAT |
| 6 | Liberar 1–5 con C1 (Use in Cloud Development) | — | — |
| 7 | ZI_PSM_CMMTITEMLASTYR | ABAP Cloud | 4 |
| 8 | ZI_PSM_CMMTITEMTEXTCUR | ABAP Cloud | 4, 7 |
| 9 | ZR_MM_MATPOSPRE | ABAP Cloud | 1, 2, 3, 5, 8 |
| 10 | ZC_MM_MATPOSPRE (DDLS) | ABAP Cloud | 9 |
| 11 | ZC_MM_MATPOSPRE (DDLX) | ABAP Cloud | 10 |
| 12 | ZSD_MM_MAT_POSPRE | ABAP Cloud | 10 |
| 13 | ZSB_MM_MAT_POSPRE_O4 (OData V4 – UI) → Publish | ABAP Cloud | 12 |
| 14 | App Fiori Elements en BAS + manifest_snippet.json | — | 13 |

## 6. Pasos en ADT (DS4)

1. Paquete Standard ABAP (Tier 2): crear las 5 vistas `_T2` → activar → Properties → API State →
   Add Release Contract **C1 – Use System-Internally**, visibilidad **Use in Cloud Development**.
2. Paquete ABAP Cloud (Tier 1): crear en orden ZI_PSM_CmmtItemLastYr, ZI_PSM_CmmtItemTextCur,
   ZR_MM_MatPospre, ZC_MM_MatPospre, metadata extension, ZSD_MM_MAT_POSPRE.
3. Crear Service Binding ZSB_MM_MAT_POSPRE_O4 (OData V4 – UI) → Publish → Preview.
4. BAS: Fiori Elements List Report (OData V4) sobre el servicio, entidad MaterialPospre;
   aplicar manifest_snippet.json.
5. Autorizaciones: incluir el servicio en el rol (S_SERVICE) del usuario final.
   Recomendado a futuro: DCL por centro/sociedad (el reporte original no tenía verificación).

## 7. Pendientes a confirmar antes de activar

- [ ] **Valor de `c_komok`** del reporte original (en ZR_MM_MatPospre está 'VBR' marcado con TODO).
- [ ] Que **Cuenta AS400 = CTAREG** (Cuenta regulatoria) de ZTCTAS_REGULAT, y que la clave sea SAKNR+KTOPL+BUKRS.
- [ ] Versión de lenguaje de ZTCTAS_REGULAT (si es ABAP Cloud, su vista pasa a Tier 1 sin liberación).
- [ ] Nombres de campo/estado de liberación en el release del cliente (abrir cada vista en ADT y revisar API State):
      I_ProductTypeText_2.ProductTypeName, I_GLAccountGroupText.AccountGroupName,
      I_ProductPlantBasic.IsMarkedForDeletion, I_CompanyCode.FinancialManagementArea, I_ProductValuationBasic.
- [ ] Que el área de valoración = centro (C001…C013). Si la valoración fuera a nivel sociedad, "Niv. centro" debe redefinirse.
- [ ] Valoración separada: se filtra ValuationType = '' (registro cabecera). Confirmar si se requieren los registros por BWTAR.
