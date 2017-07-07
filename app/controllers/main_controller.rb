require 'main.rb'
class MainController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    if(params.has_key?(:locale))
      I18n.locale = params[:locale]
    end
    @types=[{id:1,txt:I18n.t('types.table')},
           {id:2,txt:I18n.t('types.evo')},
           {id:3,txt:I18n.t('types.cam')},
           {id:4,txt:I18n.t('types.mens')},
           {id:5,txt:I18n.t('types.perio')}]
    main_params
  end
  def table
    @nentry=nil
    main_params
    if @main.type==5
      @nentry=Periodic.build_from_form(period_id,period_params) if params.has_key?(:entry)
    else
      @nentry=Entry.build_from_form(entry_id,entry_params) if params.has_key?(:entry)
    end
    generateJsonResp
  end
  def delete
    @nentry=nil
    main_params
    clas=@main.type==5 ? Periodic : Entry
    if params.has_key?(:id)
      clas.delete(del_id)
    end
    generateJsonResp
  end
  private
    def generateJsonResp
      puts @main.inspect
      inttyp=@main.type
      Periodic.make_all_entries
      @data={
        typeahead: Entry.select(:com).distinct.where("created_at >= ?", 1.month.ago).order(created_at: :desc).limit(50).all,
        type: inttyp,
        newline: inttyp<5 ? Entry.new : Periodic.new,
        comptes: Compte.order(name: :asc).all,
        moyens: Moyen.order(name: :asc).all,
        categories: Category.order(name: :asc).all,
        ord:false,
        mess: I18n.t('messages.dataload'),
        table_headers: I18n.t('table_headers'),
        image: (inttyp>1 and inttyp<5),
        locdate: I18n.t('date.formats.dp'),
        locplot: I18n.t('date.formats.default'),
        specid: @nentry==nil ? -1 : @nentry.id
      }.merge(
         inttyp<5 ? Entry.find_from_main(@main,@nentry) : {periods:Periodic.all}
        )
      respond_to do |format|
        format.json {render json: @data}
      end
    end
    def main_params
      if(params.has_key?(:locale))
        I18n.locale = params[:locale]
        puts I18n.locale
      end
      @main=MainForm.new
      if params.has_key?(:main)
        @main=MainForm.new(
          params.require(:main).permit(:date1, :date2,:type,:com,
           :poS, :page, :nb, cpS_ids: [], cpD_ids:[],
            category_ids:[], moyen_ids:[])
          ).to_type
      end
    end
    def entry_params
      params.require(:entry).permit(:date,:cpS_id, :cpD_id,:com, :pr,
       :moyen_id, :category_id, :poS )
    end
    def entry_id
      params.require(:entry).permit(:id )
    end
    def del_id
      params.require(:id)
    end
    def period_params
      params.require(:entry).permit(:lastdate,:cpS_id, :cpD_id,:com, :pr,
       :moyen_id, :category_id, :days, :months  )
    end
    def period_id
      params.require(:entry).permit(:id )
    end
end
