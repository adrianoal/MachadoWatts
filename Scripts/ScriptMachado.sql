Select * From sgcadmin.t_gnaturalperson n Where n.firstname like 'JOSE M%' and n.birthdate = to_date('27/05/1960', 'DD/MM/YYYY');
Select * From sgcadmin.t_gnaturalperson n Where n.personid in (287752, 89155783);
select * from sgcadmin.T_GPERSONCARDHOLDER pch where pch.personid in (287752, 89155783);
Select * From sgcadmin.t_gperson prs Where prs.personid = 89155783;
Select * From sgcadmin.t_gcardholder ch Where ch.cardholderid = 24788267;
Select * From sgcadmin.t_gcard cr Where cr.cardholderid = 24788267; -- 6033 4258 4946 2269
Select * From sgcadmin.t_gcustomercontract cc Where cc.customercontractid = 46404;
Select * From sgcadmin.t_gcardaccount cac Where cac.cardid = '6033425849462269';
Select * From sgcadmin.t_gcreditaccount cra Where cra.accountid = 29463673;
Select * From sgcadmin.t_gdebitaccount  dbc Where dbc.accountid = 29463673;
Select * From sgcadmin.t_gcreditoperation cra Where cra.accountid = 29463673 order by 1 desc;
Select * From sgcadmin.t_gscheduledcredit scr Where scr.accountid = 29463673 order by 1 desc;
Select * From sgcadmin.t_gdebitoperation dbo Where dbo.accountid = 29463673 order by 1 desc;
Select * From sgcadmin.t_gauthorization au Where au.cardid = '6033425849462269';

-- 6033 4258 4946 2269
SELECT 'DB', DO.ACCOUNTID, DO.OPERATIONTIME, DO.PROCESSINGDATE, DO.OPERATIONTYPEID, OP.DESCRIPTION, (DO.TRANSACTIONAMOUNT * -1), dac.availablebalance, dac.balance, ca.cardid
FROM sgcadmin.T_GDEBITOPERATION DO,                   
     sgcadmin.T_GOPERATIONTYPE OP,
     sgcadmin.t_Gdebitaccount  dac,
     sgcadmin.t_Gcardaccount   ca
WHERE DO.OPERATIONTYPEID = OP.OPERATIONTYPEID
and do.accountid = dac.accountid
And ca.accountid = do.accountid
AND   DO.ACCOUNTID in (29463673)
Union
SELECT 'CR', CO.ACCOUNTID, CO.OPERATIONTIME, CO.PROCESSINGDATE, CO.OPERATIONTYPEID, OP.DESCRIPTION, CO.TRANSACTIONAMOUNT, NULL, NULL , ca.cardid
FROM sgcadmin.T_GCREDITOPERATION CO,                   
     sgcadmin.T_GOPERATIONTYPE OP,
     sgcadmin.t_Gcardaccount   ca
WHERE CO.OPERATIONTYPEID = OP.OPERATIONTYPEID
AND   CO.ACCOUNTID in (29463673)
And ca.accountid = co.accountid
ORDER BY 2, 1, 3 desc;


Select * From ar_sunneladm.t_gauthorizationrequest ar Where ar.cardid = '3084620100343142' and trunc(ar.transactiondate) >= to_date('01/05/2018', 'DD/MM/YYYY');
Select * From ar_adm.ptc_atz_bff bff Where bff.nu_car = '3084620100343142' and bff.dt_dat_trn >= to_date('01/05/2018', 'DD/MM/YYYY');

Select * From ar_sunneladm.t_gcreditoperation cop Where cop.accountid in (2739) and cop.operationdate >= to_date('01/05/2018', 'DD/MM/YYYY');
Select * From ar_sunneladm.t_gaccountcorporatelevel Where accountid in (2739); -- 1248
Select * From ar_adm.ptc_bas b Where b.cd_bas = 1248;

/*
CD_TIP_DST_CRD  1 - CON CONTROL DE GASTOS
*/

