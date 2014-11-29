class LedgersController < ApplicationController
  # 使用する年度の設定
  YEARS = %w(2014)

  GROUP_MAP = {
      "スポーツ" => "S",
      "パトロール" => "P",
      "コミュニティ" => "C",
      "事務局" => "J",
      "収入" => "I"
  }

  # 項目ハッシュの作成
  ITEMS = %w(イベント費 登録費 消耗品費 通信費 旅費交通費 保険料 雑費
             備品 光熱費 機材 工具 修繕費
             賃借料 補助金 支払手数料 在庫保持費 生活費 積立金 人件費)
  ary = [ITEMS,ITEMS].transpose
  ITEMS_HASH = Hash[*ary.flatten]

  INCOMES = %w(内部収入-内部支援金 内部収入-年会費 内部収入-物品販売金
               内部収入-クラブ運営費 内部収入-利息 内部収入-スポーツ安全保険
               外部収入-ガード委託料 外部収入-補助金 外部収入-JLA講習会残金
               外部収入-JLA Jr.pg助成金 外部収入-鉾田市体協補助金 外部収入-外部謝礼金 その他)
  ary = [INCOMES,INCOMES].transpose
  INCOMES_HASH = Hash[*ary.flatten]


  GROUPS = %w(事務局 コミュニティ パトロール スポーツ)
  ary = [GROUPS,GROUPS].transpose
  GROUPS_HASH = Hash[*ary.flatten]

  ALL_HASH = {"all" => ""}
  BUDGET_HASH = {"収入" => "収入"}


  before_action :set_ledger, only: [:show, :edit, :update, :destroy]

  # GET /ledgers
  # GET /ledgers.json
  def index
  end

  # 各委員会用ページ
  # GET /ledgers/1
  # GET /ledgers/1.json
  def show
  end

  def view
    @search = Ledger.search(params[:q])
    @ledgers = @search.result.where.not(manager: "予算")
    @items = ALL_HASH.merge(ITEMS_HASH.merge(INCOMES_HASH))
    @groups = ALL_HASH.merge(GROUPS_HASH.merge(BUDGET_HASH))

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @ledgers }
    end
  end

  # GET /ledgers/1/edit
  def edit
  end

  def select_expense
      @year = YEARS
      @groups = GROUPS_HASH
  end

  def add_expense
    # param nil? empty? redirect_to :back
    if params[:group].blank? || params[:month].blank?
        flash[:alert] = '申請月と委員会を選択してください'
        redirect_to :action => 'select_expense'
    else
      @select_msg = params[:group] + "委員会 " + params[:year] + "年" + params[:month] + "月申請分"

      @count = Ledger.where(group: params[:group],year: params[:year],month: params[:month]).count + 1
      @no = GROUP_MAP[params[:group]] + params[:month] + "-" + @count.to_s
      @ledger = Ledger.new(no: @no, group: params[:group], year: params[:year], month: params[:month])
      @items_collect = ITEMS
      @processing = "立替日"
      @manager = "立替者"

      @ledgers = Ledger.choose(params[:group], params[:year], params[:month])
    end
  end

  def add_income
    @day = Time.now
    @no = "I" + (Ledger.where(group: "収入").count + 1).to_s
    @ledger = Ledger.new(no: @no, group: "収入", year: @day.year.to_s, month: @day.month.to_s)
    @items_collect = INCOMES
    @processing = "取得日"
    @manager = "記入責任者"

    @ledgers = Ledger.choose("収入","","");
  end

  def budget_view
    @search = Ledger.search(params[:q])
    @ledgers = @search.result.where(manager: "予算")

    # select_Tag用
    @items = ALL_HASH.merge(ITEMS_HASH)
    @groups = ALL_HASH.merge(GROUPS_HASH.merge(BUDGET_HASH))

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @ledgers }
    end
  end


  # 会計専用ページ
  def account_select
  end

  def report_select
  end

  # CSVインポート
  def import_csv_new
  end

  def import_csv
      respond_to do |format|
          if Ledger.import_csv(params[:csv_file])
              flash[:notice] = "CSVファイルの読み込みに成功。"
              format.html { redirect_to report_select_ledgers_path }
              format.json { head :no_content }
          else
              flash[:alert] = "CSVファイルの読み込みに失敗しました。ファイルを確認してください。"
              format.html { redirect_to import_csv_new_ledgers_path}
              format.json { head :no_content }
          end
      end
  end

  def import_budget
      respond_to do |format|
          if Ledger.import_budget(params[:csv_file])
              flash[:notice] = "CSVファイルの読み込みに成功。"
              format.html { redirect_to report_select_ledgers_path }
              format.json { head :no_content }
          else
              flash[:alert] = "CSVファイルの読み込みに失敗しました。ファイルを確認してください。"
              format.html { redirect_to import_csv_new_ledgers_path}
              format.json { head :no_content }
          end
      end
  end

  # report出力
  def output
    @year = params[:year].to_s
    if params[:month].present?
        @side = params[:month].to_s + "月立替分"
    else
        @side = nil
    end

    @ledgers = Ledger.choose(params[:group], params[:year], params[:month])
  end

  # 総会資料出力
  def meeting_output
    @year = params[:year].to_s
    @ledgers = Ledger.all
  end

  def income_all
    @ledgers = Ledger.choose("収入","","");
  end

  # GET /ledgers/new
  def new
    @ledger = Ledger.new
    @ledgers = Ledger.where.not(manager: "予算")
  end

  # POST /ledgers
  # POST /ledgers.json
  def create
    @ledger = Ledger.new(ledger_params)

    respond_to do |format|
      if @ledger.save
        format.html { redirect_to :back, notice: '帳簿に追加しました' }
        format.json { render 'show', status: :created, location: @ledger }
      else
        format.html { redirect_to :back, alert: '記帳に失敗しました' }
        format.json { render json: @ledger.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ledgers/1
  # PATCH/PUT /ledgers/1.json
  def update
    respond_to do |format|
      if @ledger.update(ledger_params)
        format.html { redirect_to action: 'index', notice: '指定した更新が成功しました' }
        format.json { head :no_content }
      else
        format.html { render 'edit', alert: '更新に失敗しました' }
        format.json { render json: @ledger.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ledgers/1
  # DELETE /ledgers/1.json
  def destroy
    @ledger.destroy
    respond_to do |format|
      format.html { redirect_to ledgers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ledger
      @ledger = Ledger.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ledger_params
      params.require(:ledger).permit(:no, :year, :month, :processing, :group, :manager, :item, :resume, :amount, :note)
    end
end
