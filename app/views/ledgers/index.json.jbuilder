json.array!(@ledgers) do |ledger|
  json.extract! ledger, :no, :processing, :group, :manager, :item, :resume, :amount, :note
  json.url ledger_url(ledger, format: :json)
end