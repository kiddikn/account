class LedgersController < ApplicationController
  GROUP_MAP = {
      "スポーツ" => "S",
      "パトロール" => "P",
      "コミュニティ" => "C",
      "事務局" => "J",
      "収入" => "I"
  }

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

  def select_group
  end

  def view
    @search = Ledger.search(params[:q])
    @ledgers = @search.result

    respond_to do |format|
      format.html # view.html.erb
      format.json { render json: @ledgers }
    end
  end

  # GET /ledgers/1/edit
  def edit
  end

  def select_expense
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

      @ledgers = Ledger.choose(params[:group], params[:year], params[:month])
    end
  end

  def add_income
    @day = Time.now
    @no = "I" + (Ledger.where(group: "収入").count + 1).to_s
    @ledger = Ledger.new(no: @no, group: "収入", year: @day.year.to_s, month: @day.month.to_s)
    @ledgers = Ledger.choose("収入","","");
  end

  # 会計専用ページ
  def account_select
  end


  def report_select
  end

  def output
    @year = params[:year].to_s
    @side = params[:month].to_s
    @ledgers = Ledger.choose(params[:group], params[:year], params[:month])
  end

  def income_all
    @ledgers = Ledger.choose("収入","","");
  end

  # GET /ledgers/new
  def new
    @ledger = Ledger.new
    @ledgers = Ledger.all
  end

  # POST /ledgers
  # POST /ledgers.json
  def create
    @ledger = Ledger.new(ledger_params)

    respond_to do |format|
      if @ledger.save
        format.html { redirect_to :back, notice: '帳簿に追加しました' }
        format.json { render action: 'show', status: :created, location: @ledger }
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
        format.html { render action: 'edit', alert: '更新に失敗しました' }
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
