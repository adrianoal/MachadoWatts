-- MXESPECTK-11469
Select count(1) From jmachado.tkt_transacciones_01; -- 117
Select * From jmachado.tkt_transacciones_01; -- 117


-- Analize indivudual de transacoes
Select  au.conciliationind
       ,ar.*
  From  mx_sunneladm.t_gauthorizationrequest  ar
       ,mx_sunneladm.t_gpurchaseauthorization pu
       ,mx_sunneladm.t_gauthorization         au
       ,jmachado.tkt_transacciones_01         tk
 Where ar.cardid                 = tk.cardid
   And ar.transactionamount      = tk.transactionamount
   And ar.transactiondate        = trunc(tk.transactiondate)
   And ar.authorizationrequestid = pu.authorizationrequestid
   And pu.authorizationid        = au.authorizationid; -- 107

-- Analize indivudual de transacoes no historico
Select  distinct req.*
  From  wtmx_rpt_stg.requisicao_autorizacao req
       ,jmachado.tkt_transacciones_01       tk
 Where req.nu_cartao        = tk.cardid
   And req.vl_solicitado    = tk.transactionamount
   And req.dt_datatransacao = trunc(tk.transactiondate)
   And req.cd_respostaautorizador = 0
--   And req.ds_tipotransacao       = 'ONLINE'
   And req.nu_autorizacao_financ  > 0;

-- Transacoes nao conciliadas
Select  au.conciliationind
       ,ar.*
  From  mx_sunneladm.t_gauthorizationrequest  ar
       ,mx_sunneladm.t_gpurchaseauthorization pu
       ,mx_sunneladm.t_gauthorization         au
       ,jmachado.tkt_transacciones_01         tk
 Where ar.cardid                 = tk.cardid
   And ar.transactionamount      = tk.transactionamount
   And ar.transactiondate        = trunc(tk.transactiondate)
   And ar.authorizationrequestid = pu.authorizationrequestid
   And pu.authorizationid        = au.authorizationid
   And au.conciliationind        IS NULL; -- 1

-- Transacoes ja conciliadas
Select  au.conciliationind
       ,ar.*
  From  mx_sunneladm.t_ghauthorizationrequest  ar
       ,mx_sunneladm.t_ghpurchaseauthorization pu
       ,mx_sunneladm.t_ghauthorization         au
       ,jmachado.tkt_transacciones_01         tk
 Where ar.cardid                 = tk.cardid
   And ar.transactionamount      = tk.transactionamount
   And ar.transactiondate        = trunc(tk.transactiondate)
   And ar.authorizationrequestid = pu.authorizationrequestid
   And pu.authorizationid        = au.authorizationid
   And au.conciliationind        = 'T'; -- 26

-- Transacoes ja conciliadas
Select distinct opd.*
  From  jmachado.tkt_transacciones_01               tk
       ,mx_interface.tkt_nptc_out_1030_opera_detail opd
 Where tk.cardid                 = opd.cardid
   And tk.transactionamount      = opd.transactionamount
   And tk.transactiondate        = trunc(opd.operationtime)
   And opd.controlseqid          > 0; -- 113

Select distinct opd.*
  From  jmachado.tkt_transacciones_01              tk
       ,mx_interface.tktmx_nptc_out_1030_opera_det opd
 Where tk.cardid                 = opd.cardid
   And tk.transactionamount      = opd.transactionamount
   And tk.transactiondate        = trunc(opd.operationtime)
   And opd.controlseqid          > 0; -- 95

-- Transacoes Duplicadas
Select tkt.authorizationnumber, count(1)
  From jmachado.tkt_transacciones_01 tkt
 Group by tkt.authorizationnumber
Having Count(1) > 1;

Select 'Update jmachado.tkt_transacciones_01 tkt Set tkt.CD_REQ_ATZ = ' || ar.authorizationrequestid || ', CONCILIATIONIND = ''' || au.conciliationInd || ''' Where  tkt.cardid = ''' || tk.cardid || ''' And tkt.transactionamount = ''' || tk.transactionamount || ''' And tkt.authorizationnumber = ' || tk.authorizationnumber || ';'
  From  mx_sunneladm.t_gauthorizationrequest  ar
       ,mx_sunneladm.t_gpurchaseauthorization pu
       ,mx_sunneladm.t_gauthorization         au
       ,jmachado.tkt_transacciones_01         tk
 Where ar.cardid                 = tk.cardid
   And ar.transactionamount      = tk.transactionamount
--   And au.authorizationnumber    = tk.authorizationnumber
   And ar.authorizationrequestid = pu.authorizationrequestid
   And pu.authorizationid        = au.authorizationid; -- 306

select * from MX_INTERFACE.TKT_RTKT_SGC_LOG t Where t.process_id = 61557;

-------------------------------------------------------------------------------------------
-- Conciliacao de transacoes nao conciliadas
Banco: PWTMX01
Owner: MX_INTERFACE

insert into mx_interface.tkt_rtkt_sgc_log
    (process_id
    ,line
    ,tipo_reg
    ,num_emissor
    ,nro_ref_rede
    ,nro_ref_autor
    ,dat_process
    ,tr1_cartao
    ,tr2_cartao
    ,cod_terminal
    ,nro_estab
    ,nome_estab
    ,cod_captura
    ,cod_categ_trs
    ,cod_categ_estab
    ,dat_transacao
    ,val_transacao
    ,status
    ,motivo_resp
    ,campo_01
    ,nro_seq_reg
    ,effect
    ,acquirerinstitutionid
    ,transactiontypeid)
    SELECT LG.PROCESS_ID as PROCESS_ID
          ,ROWNUM as LINE -- Cuidado com a Linha, se estiver tudo o mesmo numero pode dar deadlock
          ,'TR' as TIPO_REG
          ,TO_NUMBER(SUBSTR(A.CARDID
                           ,1
                           ,6)) as NUM_EMISSOR
          ,EAR.RETRIEVALREFERENCENUMBER as NRO_REF_REDE
          ,A.AUTHORIZATIONNUMBER as NRO_REF_AUTOR
          ,A.STATUSDATE as DAT_PROCESS
          ,'TRILHA 1' as TR1_CARTAO
          ,(SELECT RPAD(AR.CARDID
                       ,19
                       ,'0') || -- CARTÃO
                   '=' || -- SEPARADOR
                   TO_CHAR(AR.EXPIRATIONDATE
                          ,'YYMM') || -- DATA DE VALIDADE
                   '000' || -- SERVIÇO
                   '0' || -- RUF
                   '000' || -- CVT1
                   LPAD(PP.PROCESSINGPROVIDERID
                       ,2
                       ,'0') || -- PROCESSADORA
                   LPAD(P.PRODUCTID
                       ,4
                       ,'0') -- PRODUTO
            FROM   MX_SUNNELADM.T_GCARD               C
                  ,MX_SUNNELADM.T_GPROCESSINGPROVIDER PP
                  ,MX_SUNNELADM.T_GPRODUCT            P
                  ,MX_SUNNELADM.T_GCARDHOLDER         CH
                  ,MX_SUNNELADM.T_GCUSTOMERCONTRACT   CC
            WHERE  C.PROCESSINGPROVIDERID = PP.PROCESSINGPROVIDERID
            AND    C.PRODUCTID = P.PRODUCTID
            AND    C.CARDHOLDERID = CH.CARDHOLDERID
            AND    C.CUSTOMERCONTRACTID = CC.CUSTOMERCONTRACTID
            AND    A.CARDID = C.CARDID) as TR2_CARTAO
          ,EAR.CARDACCEPTORTERMINALID as COD_TERMINAL
          ,TO_NUMBER(AR.CARDACCEPTORID) as NRO_ESTAB
          ,(SELECT SUBSTR(M.NAME
                         ,1
                         ,11)
            FROM   MX_SUNNELADM.T_GMERCHANT               M
                  ,MX_SUNNELADM.T_GACQRINSTMEMBERMERCHANT AIMM
            WHERE  AIMM.MERCHANTID = M.MERCHANTID
            AND    AIMM.ACQUIRERINSTITUTIONID =
                   EAR.ACQUIRINGINSTITUTIONCODE
            AND    AIMM.CARDACCEPTORID = AR.CARDACCEPTORID) as NOME_ESTAB
          ,TO_NUMBER(EAR.CARDACCEPTORTERMINALTYPE) as COD_CAPTURA
          ,3 as COD_CATEG_TRS
          ,10000 as COD_CATEG_ESTAB
          ,AR.TRANSACTIONTIME as DAT_TRANSACAO
          ,A.CARDHOLDERBILLINGAMOUNT as VAL_TRANSACAO
          ,1 as STATUS -- Cuidado com o Status, 1 - Aprovado, 2 - Negado, 3 - Desfeito, 4 - Estornado
          ,'00' as MOTIVO_RESP
         ,NULL as CAMPO_01
          ,ROWNUM as NRO_SEQ_REG -- Cuidado com a Linha, se estiver tudo o mesmo numero pode dar deadlock
          ,NULL as EFFECT
          ,EAR.ACQUIRINGINSTITUTIONCODE as ACQUIRERINSTITUTIONID
          ,CASE AR.OFFLINEIND
               WHEN 'T' THEN
                2
               WHEN 'F' THEN
                1
           END as TRANSACTIONTYPEID
    FROM   MX_SUNNELADM.T_GAUTHORIZATION              A
          ,MX_SUNNELADM.T_GPURCHASEAUTHORIZATION      PA
          ,MX_SUNNELADM.T_GAUTHORIZATIONREQUEST       AR
          ,MX_SUNNELADM.T_GELECTRONICAUTHORIZATIONREQ EAR
          ,(SELECT (MAX(PROCESS_ID) + 1) PROCESS_ID
            FROM   MX_INTERFACE.TKT_RTKT_SGC_LOG)     LG
          ,JMACHADO.TKT_TRANSACCIONES_01              JM
    Where ar.cardid                 = jm.cardid
      And ar.transactionamount      = jm.transactionamount
      And ar.transactiondate        = trunc(jm.transactiondate)
      AND A.AUTHORIZATIONID         = PA.AUTHORIZATIONID
      AND PA.AUTHORIZATIONREQUESTID = AR.AUTHORIZATIONREQUESTID
      AND AR.AUTHORIZATIONREQUESTID = EAR.AUTHORIZATIONREQUESTID
      AND A.CONCILIATIONIND         IS NULL;

Commit;
