require 'csv'   # csv操作を可能にするライブラリ
require 'kconv' # 文字コード操作をおこなうライブラリ

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
            # 立替申請月別データ
            Ledger.where.not(group: "収入")
                  .where(year: "#{year}", month: "#{month}")
        elsif group.blank? && !year.blank? && month.blank?
            # 総会用支出データ
            Ledger.where.not(group: "収入")
                  .where(year: "#{year}")
        elsif !group.blank? && !year.blank? && month.blank?
            Ledger.where(year: "#{year}", group: "#{group}")
        elsif !group.blank? && year.blank? && month.blank?
             Ledger.where(group: "#{group}")
        else
            Ledger.where(group: "#{group}", year: "#{year}", month: "#{month}")
        end
    end

    # CSVファイルを読み込み、ユーザーを登録する
    def self.import_csv(csv_file)
        if !csv_file.nil?
            # csvファイルを受け取って文字列にする
            csv_text = csv_file.read

            #文字列をUTF-8に変換
            CSV.parse(Kconv.toutf8(csv_text)) do |row|

                ledger = Ledger.new
                ledger.no         = row[0]
                ledger.processing = row[1]
                ledger.group      = row[2]
                ledger.manager    = row[3]
                ledger.item       = row[4]
                ledger.resume     = row[5]
                ledger.amount     = row[6]
                ledger.note       = row[7]
                ledger.year       = row[8]
                ledger.month      = row[9]

                ledger.save
            end
            true
        else
            nil
        end
    end

end
