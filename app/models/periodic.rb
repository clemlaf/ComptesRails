class Periodic < ApplicationRecord
  belongs_to :cpS, class_name: "Compte", foreign_key: :cpS_id
  belongs_to :cpD, class_name: "Compte", foreign_key: :cpD_id, optional: :true
  belongs_to :moyen, optional: :true
  belongs_to :category, optional: :true

  @@param_list = [:lastdate, :cpS_id, :cpD_id, :com, :pr, :moyen_id, :category_id, :days, :months]

  def nextdate
    self.lastdate+ self.days.days + self.months.months
  end
  def self.make_all_entries()
    Periodic.all.each do |period|
      period.make_entries
    end
  end
  def make_entries()
    date=Time.now+7.days
    while nextdate < date do
      Entry.create(
        date: nextdate,
        cpS: cpS,
        cpD: cpD,
        moyen: moyen,
        category: category,
        com: com,
        pr: pr
      )
      update(lastdate:nextdate)
    end
  end
end
