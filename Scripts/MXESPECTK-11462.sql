-- MXESPECTK-11462
/*
User : jmachado
Senha: Mac042020
Banco: HWTMX01
*/

Select au.*
  From  mx_sunneladm.t_gauthorizationrequest  ar
       ,mx_sunneladm.t_gauthorization         au
       ,mx_sunneladm.t_gpurchaseauthorization pu
 Where pu.authorizationrequestid =  ar.authorizationrequestid
   And pu.authorizationid        =  au.authorizationid
   And ar.cardid                 =  '6363180041261072'
   And ar.transactiondate        =  to_date('08/07/2020', 'DD/MM/YYYY')
   And ar.transactionamount      in (1511.00, 831.05, 982.15, 1133.25, 1284.35, 1435.45, 1586.55, 1737.65);

Select *
  From mx_interface.tktmx_nptc_out_1030_opera_det opd
 Where opd.cardid               =  '6363180041261072'
   And opd.transactionamount    in (1511.00, 831.05, 982.15, 1133.25, 1284.35, 1435.45, 1586.55, 1737.65)
   And trunc(opd.operationtime) =  to_date('08/07/2020', 'DD/MM/YYYY');
