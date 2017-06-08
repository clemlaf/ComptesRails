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
           {id:4,txt:"Revenus et dépenses mensuels"}]
    main_params
  end
  def table
    @nentry=nil
    main_params
    if params.has_key?(:entry)
      @nentry=Entry.build_from_form(entry_id,entry_params)
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
      gottendata=Entry.find_from_main(@main,@nentry)
      @data={
        type: @main.type.to_i,
        newline: Entry.new,
        comptes: Compte.all,
        moyens: Moyen.all,
        categories: Category.all,
        ord:false,
        mess: "Table chargée",
        image: @main.type.to_i>1,
        locdate: I18n.t('date.formats.dp'),
        locplot: I18n.t('date.formats.default'),
        specid: @nentry==nil ? -1 : @nentry.id
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
end
