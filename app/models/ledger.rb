class Ledger < ActiveRecord::Base
    validates :group, presence: true
    validates :manager, presence: true
    validates :item, presence: true
    validates :amount, presence: true
    validates :year, presence: true
    validates :month, presence: true

    def self.choose(group, year, month)
        if group.blank? && month.blank?
            Ledger.all
        elsif group.blank? && !year.blank? && !month.blank?
            Ledger.where(year: "#{year}", month: "#{month}")
        elsif !group.blank? && !year.blank? && month.blank?
            Ledger.where(year: "#{year}", group: "#{group}")
        elsif !group.blank? && year.blank? && month.blank?
             Ledger.where(group: "#{group}")
        else
            Ledger.where(group: "#{group}", year: "#{year}", month: "#{month}")
        end
    end


    # 大竹会計が欲しい検索を追加

end
