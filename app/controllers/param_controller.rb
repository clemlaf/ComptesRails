class ParamController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    @categories=Category.all
    @moyens=Moyen.all
    @comptes=Compte.all
    puts @comptes.inspect
  end
  def update
    ar=par_table[:table].to_s.constantize
    ph=par_params
    puts ph.inspect
    isnew=ph[:id]=='new'
    if isnew
      ph.delete(:id)
      nar=ar.create(ph)
    else
      nar=ar.find(ph[:id])
      nar.update(ph)
    end
    respond_to do |format|
      format.json {render json: {
        mess: 'param updated',
        isnew: isnew,
        tabname: ar.name,
        line: (render_to_string partial:'param/pline', formats: :html, object:nar, layout:false)
      }
      }
    end
  end
  def delete
    ar=par_table[:table].to_s.constantize
    ph=par_params
    nar=ar.find(ph[:id])
    nar.delete
    respond_to do |format|
      format.json {render json: {
        mess: 'param deleted',
        tabname: ar.name,
        id:ph[:id]
      }
      }
    end
  end
  private
    def par_params
      params.require(:param).permit(:id, :name, :parent_id)
    end
    def par_table
      params.require(:param).permit(:table)
    end
end
