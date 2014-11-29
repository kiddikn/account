require 'csv'   # csv操作を可能にするライブラリ
require 'kconv' # 文字コード操作をおこなうライブラリ

class Ledger < ActiveRecord::Base
    validates :group, presence: true
    validates :manager, presence: true
    validates :item, presence: true
    validates :amount, presence: true
    validates :year, presence: true
    validates :month, presence: true

    # normalでは予算をselectさせない
    def self.choose(group, year, month)
        if group.blank? && month.blank?
            Ledger.where.not(manager: "予算")
                  .where(year: year)
        elsif group.blank? && !year.blank? && !month.blank?
            # 立替申請月別データ
            Ledger.where.not(group: "収入", manager: "予算")
                  .where(year: "#{year}", month: "#{month}")
        elsif group.blank? && !year.blank? && month.blank?
            # 総会用支出データ
            Ledger.where.not(group: "収入", manager: "予算")
                  .where(year: "#{year}")
        elsif !group.blank? && !year.blank? && month.blank?
            # 収入all一覧
            Ledger.where.not(manager: "予算")
                  .where(year: "#{year}", group: "#{group}")
        elsif !group.blank? && year.blank? && month.blank?
             Ledger.where.not(manager: "予算")
                   .where(group: "#{group}")
        else
            Ledger.where.not(manager: "予算")
                  .where(group: "#{group}", year: "#{year}", month: "#{month}")
        end
    end

    # CSVファイルを読み込み、ユーザーを登録する
    def self.import_budget(csv_file)
        unless csv_file.nil?
            # csvファイルを受け取って文字列にする
            csv_text = csv_file.read

            #文字列をUTF-8に変換
            CSV.parse(Kconv.toutf8(csv_text)) do |row|

                ledger = Ledger.new
                ledger.no         = row[0]
                ledger.year       = row[1]
                ledger.month      = row[2]
                ledger.processing = row[3]
                ledger.group      = row[4]
                ledger.manager    = row[5]
                ledger.item       = row[6]
                ledger.resume     = row[7]
                ledger.amount     = row[8]
                ledger.note       = row[9]

                ledger.save
            end
            true
        else
            nil
        end
    end

    # 支出関連
    # CSVファイルを読み込み、ユーザーを登録する
    def self.import_csv(csv_file)
        unless csv_file.nil?
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

    def self.amount_on(group, item, manager)
        if manager.blank?
          # 単純な支出のみ
          Ledger.where.not(manager: "予算")
                .where(group: group, item: item)
                .sum(:amount)

        else
          Ledger.where(manager: manager, group: group, item: item)
                .sum(:amount)
        end
    end

end
