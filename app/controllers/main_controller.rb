require 'main.rb'
class MainController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    if(params.has_key?(:locale))
      I18n.locale = params[:locale]
    end
    main_params
  end
  def update
    I18n.locale = "fr"
    @nentry=nil
    main_params
    entries_params.each do |ent|
      eid={id: ent.delete("id")}
      Entry.build_from_form(eid,ent)
    end
    generateJsonResp
  end
  def table
    @nentry=nil
    main_params
    @nentry=@model.build_from_form(entry_id,entry_params) if params.has_key?(:entry)
    generateJsonResp
  end
  def delete
    @nentry=nil
    main_params
    if params.has_key?(:id)
      @model.delete(del_id)
    end
    generateJsonResp
  end
  private
    def generateJsonResp
      puts @main.inspect
      inttyp=@main.type
      Periodic.make_all_entries
      newline= inttyp<5 ? Entry.new : Periodic.new
      newline.cpS=Compte.find(@main.cpS_ids.first) unless @main.cpS_ids.length==0
      @data={
        typeahead: Entry.select(:com).where("created_at >= ?", 1.month.ago).order(created_at: :desc).limit(50).all,
        type: inttyp,
        newline: newline,
        comptes: Compte.order(name: :asc).all,
        moyens: Moyen.order(name: :asc).all,
        categories: Category.order(name: :asc).all,
        ord:false,
        mess: I18n.t('messages.dataload'),
        table_headers: I18n.t('table_headers'),
        image: (inttyp>1 and inttyp<5),
        locdate: I18n.t('date.formats.dp'),
        locplot: I18n.t('date.formats.default'),
        specid: @nentry==nil ? -1 : @nentry.id,
      }.merge  @class.new(@main,@nentry).data
      respond_to do |format|
        format.json {render json: @data}
      end
    end
    def main_params
      if(params.has_key?(:locale))
        I18n.locale = params[:locale]
        puts I18n.locale
      end
      @types=[{id:1,txt:I18n.t('types.table'),class:MainHelper::MainTable},
                {id:2,txt:I18n.t('types.evo'),class: MainHelper::MainSoldeGraph},
                {id:3,txt:I18n.t('types.cam'),class:MainHelper::MainCamembertGraph},
                {id:4,txt:I18n.t('types.mens'),class:MainHelper::MainMonthlyRecap},
                {id:5,txt:I18n.t('types.perio'),class:MainHelper::MainPeriodTable}]
      @main=MainForm.new
      if params.has_key?(:main)
        @main=MainForm.new(
          params.require(:main).permit(:date1, :date2,:type,:com,
           :poS, :page, :nb, cpS_ids: [], cpD_ids:[],
            category_ids:[], moyen_ids:[])
          ).to_type
      end
      @class=@types[@main.type-1][:class]
      @model=@class.model
    end
    def entry_params
      params.require(:entry).permit(*@model.param_list )
    end
    def entry_id
      params.require(:entry).permit(:id )
    end
    def del_id
      params.require(:id)
    end
    def entries_params
      intpar=params.permit(entries: [:id, *Entry.param_list])
      intpar[:entries]
    end
end
