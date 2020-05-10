

-- disbaled triggers
select 'ALTER TABLE ' || n.nspname || '.' || t.tgrelid::regclass || ' ENABLE TRIGGER ' || t.tgname || ';'
from pg_catalog.pg_trigger t
join pg_catalog.pg_class c
on t.tgrelid = c.oid
join pg_catalog.pg_namespace n
on c.relnamespace = n.oid
where n.nspname = current_schema()
and t.tgname like 'bucardo%'
;


ALTER TABLE corp.account DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.account DISABLE TRIGGER bucardo_note_trunc_sync_corp_account;
ALTER TABLE corp.add_company_request DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.add_company_request DISABLE TRIGGER bucardo_note_trunc_sync_corp_add_company_request;
ALTER TABLE corp.add_withdraw_fund_request DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.add_withdraw_fund_request DISABLE TRIGGER bucardo_note_trunc_sync_corp_add_withdraw_fund_request;
ALTER TABLE corp.bulk_order DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.bulk_order DISABLE TRIGGER bucardo_note_trunc_sync_corp_bulk_order;
ALTER TABLE corp.card_config DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.card_config DISABLE TRIGGER bucardo_note_trunc_sync_corp_card_config;
ALTER TABLE corp.cardprogram DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.cardprogram DISABLE TRIGGER bucardo_note_trunc_sync_corp_cardprogram;
ALTER TABLE corp.close_card_action DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.close_card_action DISABLE TRIGGER bucardo_note_trunc_sync_corp_close_card_action;
ALTER TABLE corp.close_card_log DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.close_card_log DISABLE TRIGGER bucardo_note_trunc_sync_corp_close_card_log;
ALTER TABLE corp.close_card_order DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.close_card_order DISABLE TRIGGER bucardo_note_trunc_sync_corp_close_card_order;
ALTER TABLE corp.company DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.company DISABLE TRIGGER bucardo_note_trunc_sync_corp_company;
ALTER TABLE corp.company_manager_contribution DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.company_manager_contribution DISABLE TRIGGER bucardo_note_trunc_sync_corp_company_manager_contribution;
ALTER TABLE corp.company_product_attributes DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.company_product_attributes DISABLE TRIGGER bucardo_note_trunc_sync_corp_company_product_attributes;
ALTER TABLE corp.corporate_agreement DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.corporate_agreement DISABLE TRIGGER bucardo_note_trunc_sync_corp_corporate_agreement;
ALTER TABLE corp.corporate DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.corporate DISABLE TRIGGER bucardo_note_trunc_sync_corp_corporate;
ALTER TABLE corp.disbursement DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.disbursement DISABLE TRIGGER bucardo_note_trunc_sync_corp_disbursement;
ALTER TABLE corp.disbursement_log DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.disbursement_log DISABLE TRIGGER bucardo_note_trunc_sync_corp_disbursement_log;
ALTER TABLE corp.employee_card DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.employee_card DISABLE TRIGGER bucardo_note_trunc_sync_corp_employee_card;
ALTER TABLE corp.employee DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.employee DISABLE TRIGGER bucardo_note_trunc_sync_corp_employee;
ALTER TABLE corp.expire_card_log DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.expire_card_log DISABLE TRIGGER bucardo_note_trunc_sync_corp_expire_card_log;
ALTER TABLE corp.export_documents DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.export_documents DISABLE TRIGGER bucardo_note_trunc_sync_corp_export_documents;
ALTER TABLE corp.funding_account DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.funding_account DISABLE TRIGGER bucardo_note_trunc_sync_corp_funding_account;
ALTER TABLE corp.ifi_details DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.ifi_details DISABLE TRIGGER bucardo_note_trunc_sync_corp_ifi_details;
ALTER TABLE corp.internalcontacts DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.internalcontacts DISABLE TRIGGER bucardo_note_trunc_sync_corp_internalcontacts;
ALTER TABLE corp."order" DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp."order" DISABLE TRIGGER bucardo_note_trunc_sync_corp_order;
ALTER TABLE corp.paymentlog DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.paymentlog DISABLE TRIGGER bucardo_note_trunc_sync_corp_paymentlog;
ALTER TABLE corp.payout DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.payout DISABLE TRIGGER bucardo_note_trunc_sync_corp_payout;
ALTER TABLE corp.payout_log DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.payout_log DISABLE TRIGGER bucardo_note_trunc_sync_corp_payout_log;
ALTER TABLE corp.report_archive DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.report_archive DISABLE TRIGGER bucardo_note_trunc_sync_corp_report_archive;
ALTER TABLE corp.report_configuration DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.report_configuration DISABLE TRIGGER bucardo_note_trunc_sync_corp_report_configuration;
ALTER TABLE corp.report_section DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.report_section DISABLE TRIGGER bucardo_note_trunc_sync_corp_report_section;
ALTER TABLE corp.reseller DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.reseller DISABLE TRIGGER bucardo_note_trunc_sync_corp_reseller;
ALTER TABLE corp.revokelog DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.revokelog DISABLE TRIGGER bucardo_note_trunc_sync_corp_revokelog;
ALTER TABLE corp.spend_proofs DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.spend_proofs DISABLE TRIGGER bucardo_note_trunc_sync_corp_spend_proofs;
ALTER TABLE corp.test1 DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.test1 DISABLE TRIGGER bucardo_note_trunc_sync_corp_test1;
ALTER TABLE corp.user_documents DISABLE TRIGGER bucardo_delta;
ALTER TABLE corp.user_documents DISABLE TRIGGER bucardo_note_trunc_sync_corp_user_documents;
