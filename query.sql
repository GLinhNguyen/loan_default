SELECT loan_id, cl.client_id, l.amount as "loan amount",  1999 - year(birth_date) AS age, cl.gender,
        case 
		WHEN t.operation LIKE 'VYBER KARTOU' THEN 'credit card withdrawal'
        WHEN t.operation LIKE 'VKLAD' THEN 'credit in cash'
        WHEN t.operation LIKE 'VYBER' THEN 'withdrawal in cash'
        WHEN t.operation LIKE 'PREVOD Z UCTU' THEN 'collection from another bank'
        WHEN t.operation LIKE 'PREVOD NA UCET' THEN 'remittance to another bank'
        ELSE 'other'
        end as 'mode_of_transaction',
        count(t.trans_id) as num_trans_be4_loan,
      
        sum(case when t.type = "PRIJEM" then t.amount else 0 end) as total_deposit_be4_loan,
        sum(case when t.type = "VYDAJ" then -t.amount else 0 end) as total_withdrawal_be4_loan,
		avg(t.balance) as avg_balance_be4_loan,
        
       case 
		WHEN o.k_symbol LIKE  'POJISTNE' THEN 'insurance payment'
        WHEN o.k_symbol LIKE 'SIPO' THEN 'household'
        WHEN o.k_symbol LIKE 'UVER' THEN 'loan payment'
        WHEN o.k_symbol LIKE 'LEASING' THEN 'leasing'
        ELSE 'other'
        end as 'debit_payment_purpose',
        
        A11 as avg_salary, A12 as unemployment_rate,
        l.status
        
from loan l
LEFT join trans t on t.account_id = l.account_id
LEFT join disp d on d.account_id = l.account_id
LEFT join client cl on cl.client_id = d.client_id
LEFT join district dt on dt.district_id = cl.district_id
left join financial.order clientloano on o.account_id = l.account_id

where l.date > t.date --  transaction up to the loan start date
and d.type = 'OWNER'
and l.status in ('A', 'B')  -- only finished loan

group by  l.loan_id, cl.client_id, cl.gender, age, dt.A11, dt.A12, l.status
