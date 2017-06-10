require 'main.rb'
class MainController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    if(params.has_key?(:locale))
      I18n.locale = params[:locale]
    end
    @types=[{id:1,txt:"Table"},
           {id:2,txt:"Évolution solde"},
           {id:3,txt:"Camembert dépenses"},
           {id:4,txt:"Revenus et dépenses mensuels"},
           {id:5,txt:"Opérations périodiques"}]
    main_params
  end
  def table
    @nentry=nil
    @nperiod=nil
    main_params
    if @main.type==5
      @nperiod=Periodic.build_from_form(period_id,period_params) if params.has_key?(:entry)
    else
      @nentry=Entry.build_from_form(entry_id,entry_params) if params.has_key?(:entry)
    end
    generateJsonResp
  end
  def delete
    @nentry=nil
    main_params
    if params.has_key?(:id)
      Entry.delete(del_id)
    end
    generateJsonResp
  end
  private
    def generateJsonResp
      puts @main.inspect
      inttyp=@main.type
      Periodic.make_all_entries
      if inttyp < 5
         gottendata=Entry.find_from_main(@main,@nentry)
      else
         gottendata={periods:Periodic.all}
      end
      @data={
        typeahead: Entry.select(:com).distinct.where("created_at <= ?", 1.month.ago).order(created_at: :desc).limit(50).all,
        type: inttyp,
        newline: inttyp<5 ? Entry.new : Periodic.new,
        comptes: Compte.all,
        moyens: Moyen.all,
        categories: Category.all,
        ord:false,
        mess: "Table chargée",
        image: (inttyp>1 and inttyp<5),
        locdate: I18n.t('date.formats.dp'),
        locplot: I18n.t('date.formats.default'),
        specid: @nentry==nil ? (@nperiod==nil ? -1 : @nperiod.id) : @nentry.id
      }.merge(gottendata)
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
          )
      end
      @main.to_type
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
