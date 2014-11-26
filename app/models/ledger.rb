class Ledger < ActiveRecord::Base
    validates :group, presence: true
    validates :manager, presence: true
    validates :item, presence: true
    validates :amount, presence: true
    validates :year, presence: true
    validates :month, presence: true

    def self.search(search) #self.でクラスメソッドとしている
        if search.nil? || search.empty? # Controllerから渡されたパラメータが!= nilの場合は、titleカラムを部分一致検索
            Ledger.all #全て表示。
        else
            Ledger.where(group: "#{search}")
        end
    end

end
