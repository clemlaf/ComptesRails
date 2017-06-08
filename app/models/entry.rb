require 'main.rb'
class Entry < ApplicationRecord
  belongs_to :cpS, class_name: "Compte", foreign_key: :cpS_id
  belongs_to :cpD, class_name: "Compte", foreign_key: :cpD_id, optional: :true
  belongs_to :moyen, optional: :true
  belongs_to :category, optional: :true

  def self.build_from_form(idp,attrs)
    id=idp[:id]
    if attrs.has_key?(:pr)
      prf=attrs[:pr].to_f
      attrs[:pr]=(100.0*prf+(prf>0?0.5:-0.5)).to_i
    end
    if id=="new" or not Entry.exists?(id)
      nentry=Entry.create(attrs)
    else
      nentry=Entry.find(id)
      nentry.update(attrs)
    end
    puts nentry.inspect
    puts nentry.errors.full_messages
    return nentry
  end
  def self.find_from_main(main,nentry)
    # initialisation des sorties
    outh={}
    outarr=[]
    soldarr=[]
    datarr=[]
    mh=main.to_hash()
    # filtre  sur le compte
    cptab=mh[:cpS]
    date_field=Entry.arel_table[:date]
    creat_field=Entry.arel_table[:created_at]
    if mh.has_key?(:cpD)
      relp=Entry.where("cpS" => cptab, "cpD" => mh[:cpD])
      relm=Entry.where("cpS" => mh[:cpD], "cpD" => cptab)
    else
      relp=Entry.where("cpS" => cptab)
      relm=Entry.where("cpD" => cptab)
    end
    soldepointe=relp.where(poS: true).sum(:pr)-relm.where(poD: true).sum(:pr)
    rel=relp.or(relm) # relation pour la requete principale
    puts main.type.inspect
    # filtre sur la date
    d1=main.getDate1
    d2=main.getDate2
    rel=rel.where(date_field.gt(d1)) if d1
    rel=rel.where(date_field.lt(d2)) if d2
    mh.delete(:cpS)
    mh.delete(:cpD)
    # fitre sur les autres champs
    rel=rel.where(mh)
    case main.type.to_i
    when 1
      # table
      allc=rel.count
      # pagination
      lim=main.nb.to_i
      page=main.page.to_i
      nbpage=(allc-1)/lim+1
      page=nbpage if page==0 or page>nbpage
      off=(page-1)*lim
      rel=rel.order(:date,:id)
      # no limit on pagination for graphes
      rel=rel.limit(lim).offset(off) unless main.type.to_i >1
      # solde
      sold=0.0 # pour graphe solde ou table initalisée à 0
      if rel.any?
        firstent=rel.first
        # cas pour la table paginée
        relp=relp.where(mh).where(date_field.lt(firstent.date)).or(relp.where(date: firstent.date).where('id < ?',firstent.id))
        relm=relm.where(mh).where(date_field.lt(firstent.date)).or(relm.where(date: firstent.date).where('id < ?',firstent.id))
        sold=relp.sum(:pr)-relm.sum(:pr) unless allc < lim and off==0
      end
      # boucle sur les entrées pour les mettre dans le bon sens et calculer les soldes
      foundn=false
      rel.each do |entr|
        foundn|=(entr.id==nentry.id) unless nentry==nil
        outarr.push(entr.reverse(cptab))
        sold+=entr.pr
        soldarr.push sold.to_f/100.0
      end
      if (not foundn) and nentry!=nil
        outarr.push(nentry)
        soldarr.push nil
      end
      # mise en forme des sorties
      outh[:entries]=outarr
      outh[:soldes]=soldarr
      outh[:page]=page
      outh[:nbpage]=nbpage
      outh[:solde_p]=soldepointe.to_f/100.0
      outh[:typeahead]=Entry.select(:com).distinct.where("created_at <= ?", 1.month.ago).order(created_at: :desc).limit(50).all
    when 2
      #graphe solde
      rel=rel.order(:date,:id)
      sold=0.0 # pour graphe solde ou table initalisée à 0
      rel.each do |entr|
        outarr.push(entr.reverse(cptab))
        sold+=entr.pr
        soldarr.push [
          entr.date.respond_to?(:to_time) ? entr.date.to_time.to_i*1000 : nil,
          sold.to_f/100.0
        ]
      end
      outh[:soldes]=soldarr
    when 3
      relp=relp.where(date_field.gt(d1)) if d1
      relp=relp.where(date_field.lt(d2)) if d2
      relm=relm.where(date_field.gt(d1)) if d1
      relm=relm.where(date_field.lt(d2)) if d2
      # filtre sur les autres champs
      relp=relp.where(mh)
      relm=relm.where(mh)
      catp=relp.group(:category).sum(:pr)
      catm=relm.group(:category).sum(:pr)
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
      outh[:camemb]=data
      # camembert dep
      puts 'camembert'
    when 4
      # recap par mois
      puts 'recap'
      relp=relp.where(date_field.gt(d1)) if d1
      relp=relp.where(date_field.lt(d2)) if d2
      relm=relm.where(date_field.gt(d1)) if d1
      relm=relm.where(date_field.lt(d2)) if d2
      # filtre sur les autres champs
      relp=relp.where(mh)
      relm=relm.where(mh)
      allp=relp.order(:date).group("strftime('%Y-%m-01',date)").sum(:pr)
      allm=relm.order(:date).group("strftime('%Y-%m-01',date)").sum(:pr)
      datap=[]
      datam=[]
      datar=[]
      inskeys=[]
      delta=300*60*60*24*12
      allp.each_pair do |k,v|
        time=k.to_datetime.to_i*1000
        datap << [time, v/100.0]
        negv= allm.has_key?(k) ? -1*allm[k]/100.0 : 0.0
        datam << [time,negv]
        datar << [time+delta, v/100.0+negv]
        inskeys << k
      end
      allm.each_pair do |k,v|
        if not inskeys.include? k
          time=k.to_datetime.to_i*1000
          datam << [time, -v/100.0]
          datap << [time, 0.0]
          datar << [time+delta, -v/100.0]
        end
      end
      outh[:recap]=[
        {label:I18n.t('pos'), data: datap},
        {label:I18n.t('neg'), data: datam},
        {label:I18n.t('net'), data: datar}
      ]
    end
    outh
  end

  def reverse(cptab)
    cptab.each do |cpid|
      if self.cpS_id == cpid
        break
      end
      if self.cpD_id == cpid and self.cpS_id !=cpid
        self.cpD_id=self.cpS_id
        self.cpS_id=cpid
        self.pr=-self.pr
        tmp=self.poD
        self.poD=self.poS
        self.poS=tmp
        break
      end
    end
    self
  end
  def as_json(options=nil)
    json=super(options)
    json["date"]=I18n.l(json["date"]) if json["date"]
    json
  end
end
