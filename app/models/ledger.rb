class Ledger < ActiveRecord::Base
    validates :group, presence: true
    validates :manager, presence: true
    validates :item, presence: true
    validates :amount, presence: true

end
