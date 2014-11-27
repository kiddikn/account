class Ledger < ActiveRecord::Base
    validates :group, presence: true
    validates :manager, presence: true
    validates :item, presence: true
    validates :amount, presence: true
    validates :year, presence: true
    validates :month, presence: true

    def self.search(search) #self.でクラスメソッドとしている
        if search.nil? || search.empty?
            Ledger.all
        else
            Ledger.where(group: "#{search}")
        end
    end

    def self.choose(group, year, month)
        if group.empty? && year.empty? && month.empty?
            Ledger.all
        else
            Ledger.where(group: "#{group}", year: "#{year}", month: "#{month}")
        end
    end

    # 大竹会計が欲しい検索を追加

end
