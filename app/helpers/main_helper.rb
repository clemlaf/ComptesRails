module MainHelper
  class MainRelation
    @@model=Entry
    def self.model
      @@model
    end
    def initialize(main, nentry)
    #def self.data_from_main(main,nentry)
      # initialisation des sorties
      # filtre  sur le compte
      @main=main
      @new_entry=nentry
      @date_field=Entry.arel_table[:date]
      @creat_field=Entry.arel_table[:created_at]
      puts @main.cpD_ids.inspect
      if not @main.cpD_ids.empty?
        @relp=Entry.where("cpS" => @main.cpS_ids, "cpD" => @main.cpD_ids)
        @relm=Entry.where("cpS" => @main.cpD_ids, "cpD" => @main.cpS_ids)
      else
        @relp=Entry.where("cpS" => @main.cpS_ids)
        @relm=Entry.where("cpD" => @main.cpS_ids)
      end
      @rel=@relp.or(@relm)
      # filtre sur la date
      @rel=@rel.where(@date_field.gt(@main.date1)) if @main.date1
      @rel=@rel.where(@date_field.lt(@main.date2)) if @main.date2
      # fitre sur le champ commentaire
      @rel=@rel.where("com like ?", "%"+@main.com+"%") unless @main.com.empty?
      # fitre sur les autres champs
      @rel=@rel.where(@main.to_hash)
    end
  end
  class MainTable < MainRelation
    def data
      soldepointe=@relp.where(poS: true).sum(:pr)-@relm.where(poD: true).sum(:pr)
      # table
      allc=@rel.count
      # pagination
      lim=@main.nb
      page=@main.page
      nbpage=(allc-1)/lim+1
      page=nbpage if page==0 or page>nbpage
      off=[(page-1)*lim, allc-lim].min
      @rel=@rel.order(:date,:id)
      # no limit on pagination for graphes
      @rel=@rel.limit(lim).offset(off)
      # solde
      sold=0.0 # pour table initalisée à 0
      if @rel.any?
        firstent=@rel.first
        # cas pour la table paginée
        @relp=@relp.where(@main.to_hash).where(@date_field.lt(firstent.date)).or(@relp.where(date: firstent.date).where('id < ?',firstent.id))
        @relm=@relm.where(@main.to_hash).where(@date_field.lt(firstent.date)).or(@relm.where(date: firstent.date).where('id < ?',firstent.id))
        sold=@relp.sum(:pr)-@relm.sum(:pr) unless allc < lim and off==0
      end
      # boucle sur les entrées pour les mettre dans le bon sens et calculer les soldes
      foundn=false
      outarr=[]
      soldarr=[]
      @rel.each do |entr|
        foundn|=(entr.id==@new_entry.id) unless @new_entry==nil
        outarr.push(entr.reverse(@main.cpS_ids))
        sold+=entr.pr
        soldarr.push sold.to_f/100.0
      end
      if (not foundn) and @new_entry!=nil
        outarr.push(@new_entry)
        soldarr.push nil
      end
      # mise en forme des sorties
      {
        entries: outarr,
        soldes: soldarr,
        page: page,
        nbpage: nbpage,
        solde_p: soldepointe.to_f/100.0,
        first_parent: Compte.get_first_parent(@main.cpS_ids)
      }
    end
  end
  class MainSoldeGraph < MainRelation
    def data
      outarr=[]
      soldarr=[]
      #graphe solde
      @rel=@rel.order(:date,:id)
      sold=0.0 # pour graphe solde ou table initalisée à 0
      @rel.each do |entr|
        nentr=entr.reverse(@main.cpS_ids)
        if not nentr.issym?(@main.cpS_ids,@main.cpD_ids)
        outarr.push(nentr)
        sold+=nentr.pr
        soldarr.push [
          nentr.date.respond_to?(:to_time) ? nentr.date.to_time.to_i*1000 : nil,
          sold.to_f/100.0
        ]
        end
      end
      {soldes: soldarr}
    end
  end
  class MainRelationPM < MainRelation
    def initialize(main, nentry)
      super(main, nentry)
      @relp=@relp.where(@date_field.gt(@main.date1)) if @main.date1
      @relp=@relp.where(@date_field.lt(@main.date2)) if @main.date2
      @relm=@relm.where(@date_field.gt(@main.date1)) if @main.date1
      @relm=@relm.where(@date_field.lt(@main.date2)) if @main.date2
      # fitre sur le champ commentaire
      @relp=@relp.where("com like ?", "%"+@main.com+"%") unless @main.com.empty?
      @relm=@relm.where("com like ?", "%"+@main.com+"%") unless @main.com.empty?
      # filtre sur les autres champs
      @relp=@relp.where(@main.to_hash)
      @relm=@relm.where(@main.to_hash)
    end
  end
  class MainCamembertGraph < MainRelationPM
    def data
      catp=@relp.group(:category).sum(:pr)
      catm=@relm.group(:category).sum(:pr)
      catm.each_pair do |k,v|
        if catp.has_key? k
          catp[k]-=v
        else
          catp[k]=-v
        end
      end
      data=[]
      catp.each_pair do |k,v|
        data << {label: k.name, data:-v} unless k==nil or v>0.0
      end
      {camemb: data}
    end
  end
  class MainMonthlyRecap < MainRelationPM
    def data
      allpp=@relp.where("pr >= ?", 0).order(:date).group("strftime('%Y-%m-01',date)").sum(:pr)
      allpm=@relp.where("pr < ?", 0).order(:date).group("strftime('%Y-%m-01',date)").sum(:pr)
      allmp=@relm.where("pr <= ?", 0).order(:date).group("strftime('%Y-%m-01',date)").sum(:pr)
      allmm=@relm.where("pr > ?", 0).order(:date).group("strftime('%Y-%m-01',date)").sum(:pr)
      keys=(allpp.keys+allpm.keys+allmp.keys+allmm.keys).uniq
      datap=[]
      datam=[]
      datar=[]
      delta=300*60*60*24*12
      average=0.0
      mintime=keys[0].to_datetime
      maxtime=mintime
      keys.each do |k|
        time=k.to_datetime
        mintime=[mintime,time].min
        maxtime=[maxtime,time].max
        time=time.to_i*1000
        posv= allpp.has_key?(k) ? allpp[k]/100.0 : 0.0
        posv+= allmp.has_key?(k) ? -1*allmp[k]/100.0 : 0.0
        negv= allmm.has_key?(k) ? -1*allmm[k]/100.0 : 0.0
        negv+= allpm.has_key?(k) ? allpm[k]/100.0 : 0.0
        datap << [time, posv]
        datam << [time, negv]
        datar << [time+delta, posv+negv]
        average+=posv+negv
      end
      puts ((Time.at(maxtime.to_i)-Time.at(mintime.to_i))/(1.month))
      average/=((Time.at(maxtime.to_i)-Time.at(mintime.to_i))/(1.month)).round.to_f
      mintime=mintime.to_i*1000
      maxtime=maxtime.to_i*1000
      mybars={
        show:true,
        barWidth:delta
      }
      {recap: [
          {label:I18n.t('pos'), data: datap, bars:mybars},
          {label:I18n.t('neg'), data: datam, bars:mybars},
          {label:I18n.t('net'), data: datar, bars:mybars},
          {label:I18n.t('average'), data:
            [ [mintime, average], [maxtime, average] ],
            lines: {show: true }, bars:{show:false}
          }
        ]
      }
    end
  end
  class MainPeriodTable
    @@model=Periodic
    def self.model
      @@model
    end
    def initialize(main,nentry)
    end
    def data
      {periods:Periodic.all}
    end
  end
end
