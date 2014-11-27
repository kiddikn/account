class Ledger < ActiveRecord::Base
    validates :group, presence: true
    validates :manager, presence: true
    validates :item, presence: true
    validates :amount, presence: true
    validates :year, presence: true
    validates :month, presence: true

    def self.group(search) #self.でクラスメソッドとしている
        if search.blank?
            Ledger.all
        else
            Ledger.where(group: "#{search}")
        end
    end

    def self.choose(group, year, month)
        if group.blank? && year.blank? && month.blank?
            Ledger.all
        else
            Ledger.where(group: "#{group}", year: "#{year}", month: "#{month}")
        end
    end

    # 大竹会計が欲しい検索を追加

end
