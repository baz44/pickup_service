require 'pickup_service'
require 'timecop'

describe PickupService do
  describe ".perform" do
    it "should return today and tomorrow if given cut off time hasn't passed yet" do
      Timecop.freeze(Time.new(2014,9,15,11))
      expect(PickupService.perform("2pm")).to eql([{:date=>"Mon, 15 Sep 2014", :description=>"Today"},
                                                   {:date=>"Tue, 16 Sep 2014", :description=>"Tomorrow"}])
    end

    it "should return today and tomorrow and wendesday if given cut off time hasn't passed yet and 3 dates needed" do
      Timecop.freeze(Time.new(2014,9,15,11))
      expect(PickupService.perform("2pm", 3)).to eql([{:date=>"Mon, 15 Sep 2014", :description=>"Today"},
                                                      {:date=>"Tue, 16 Sep 2014", :description=>"Tomorrow"},
                                                      {:date=>"Wed, 17 Sep 2014", :description=>"Wednesday"}])
    end

    it "should return tomorrow and Wed if cut off date has passed" do
      Timecop.freeze(Time.new(2014,9,15,15))
      expect(PickupService.perform("2pm")).to eql([{:date=>"Tue, 16 Sep 2014", :description=>"Tomorrow"},
                                                   {:date=>"Wed, 17 Sep 2014", :description=>"Wednesday"}])
    end

    it "should return Mon and Tue if today is friday and cut off date has passed and tomorrow is a weekend" do
      Timecop.freeze(Time.new(2014,9,12,15))
      expect(PickupService.perform("2pm")).to eql([{:date=>"Mon, 15 Sep 2014", :description=>"Monday"},
                                                   {:date=>"Tue, 16 Sep 2014", :description=>"Tuesday"}])
    end

    it "should return Today and Mon if today is friday and cut off date has not passed and tomorrow is a weekend" do
      Timecop.freeze(Time.new(2014,9,12,11))
      expect(PickupService.perform("2pm")).to eql([{:date=>"Fri, 12 Sep 2014", :description=>"Today"},
                                                   {:date=>"Mon, 15 Sep 2014", :description=>"Monday"}])
    end

    it "should return Mon and Tue if today is saturday and cut off date has passed and tomorrow is a weekend" do
      Timecop.freeze(Time.new(2014,9,13,15))
      expect(PickupService.perform("2pm")).to eql([{:date=>"Mon, 15 Sep 2014", :description=>"Monday"},
                                                   {:date=>"Tue, 16 Sep 2014", :description=>"Tuesday"}])
    end

    it "should return Tomorrow and Tue if today is sunday and cut off date has passed" do
      Timecop.freeze(Time.new(2014,9,14,15))
      expect(PickupService.perform("2pm")).to eql([{:date=>"Mon, 15 Sep 2014", :description=>"Tomorrow"},
                                                   {:date=>"Tue, 16 Sep 2014", :description=>"Tuesday"}])
    end


    it "should return Tuesday and Wednesday if today is friday and cut off date has passed and monday is a bank holiday" do
      Timecop.freeze(Time.new(2014,8,22,16))
      expect(PickupService.perform("4pm")).to eql([{:date=>"Tue, 26 Aug 2014", :description=>"Tuesday"},
                                                   {:date=>"Wed, 27 Aug 2014", :description=>"Wednesday"}])
    end
  end
end
