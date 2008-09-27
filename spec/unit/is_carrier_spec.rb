require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Jpmobile::Mobile' do
  Spec::Fixture::Base.new self, [ :klass, :carrier ] => :expected do
    filters({
      :klass => proc {|val| Jpmobile::Mobile.const_get(val) },
      :carrier => proc {|val| "#{val}?" },
    })

    desc_filters({
      :klass => proc {|val| "::#{val.to_s}" },
      :carrier => proc {|val| "#{val}?" },
    })

    it ":klass#:carrier should be return :expected" do |input, expected|
      input[:klass].new({}).__send__(input[:carrier]).should == expected
    end

    set_fixtures([
      [ %w[ Docomo docomo    ] => true ],
      [ %w[ Docomo au        ] => false ],
      [ %w[ Docomo softbank  ] => false ],
      [ %w[ Docomo vodafone  ] => false ],
      [ %w[ Docomo jphone    ] => false ],
      [ %w[ Docomo emobile   ] => false ],
      [ %w[ Docomo willcom   ] => false ],
      [ %w[ Docomo ddipocket ] => false ],

      [ %w[ Au docomo    ] => false ],
      [ %w[ Au au        ] => true ],
      [ %w[ Au softbank  ] => false ],
      [ %w[ Au vodafone  ] => false ],
      [ %w[ Au jphone    ] => false ],
      [ %w[ Au emobile   ] => false ],
      [ %w[ Au willcom   ] => false ],
      [ %w[ Au ddipocket ] => false ],

      [ %w[ Softbank docomo    ] => false ],
      [ %w[ Softbank au        ] => false ],
      [ %w[ Softbank softbank  ] => true ],
      [ %w[ Softbank vodafone  ] => false ],
      [ %w[ Softbank jphone    ] => false ],
      [ %w[ Softbank emobile   ] => false ],
      [ %w[ Softbank willcom   ] => false ],
      [ %w[ Softbank ddipocket ] => false ],

      [ %w[ Vodafone docomo    ] => false ],
      [ %w[ Vodafone au        ] => false ],
      [ %w[ Vodafone softbank  ] => true  ],
      [ %w[ Vodafone vodafone  ] => true  ],
      [ %w[ Vodafone jphone    ] => false ],
      [ %w[ Vodafone emobile   ] => false ],
      [ %w[ Vodafone willcom   ] => false ],
      [ %w[ Vodafone ddipocket ] => false ],

      [ %w[ Jphone docomo    ] => false ],
      [ %w[ Jphone au        ] => false ],
      [ %w[ Jphone softbank  ] => true  ],
      [ %w[ Jphone vodafone  ] => true  ],
      [ %w[ Jphone jphone    ] => true  ],
      [ %w[ Jphone emobile   ] => false ],
      [ %w[ Jphone willcom   ] => false ],
      [ %w[ Jphone ddipocket ] => false ],

      [ %w[ Emobile docomo    ] => false ],
      [ %w[ Emobile au        ] => false ],
      [ %w[ Emobile softbank  ] => false ],
      [ %w[ Emobile vodafone  ] => false ],
      [ %w[ Emobile jphone    ] => false ],
      [ %w[ Emobile emobile   ] => true  ],
      [ %w[ Emobile willcom   ] => false ],
      [ %w[ Emobile ddipocket ] => false ],

      [ %w[ Willcom docomo    ] => false ],
      [ %w[ Willcom au        ] => false ],
      [ %w[ Willcom softbank  ] => false ],
      [ %w[ Willcom vodafone  ] => false ],
      [ %w[ Willcom jphone    ] => false ],
      [ %w[ Willcom emobile   ] => false ],
      [ %w[ Willcom willcom   ] => true  ],
      [ %w[ Willcom ddipocket ] => false ],

      [ %w[ Ddipocket docomo    ] => false ],
      [ %w[ Ddipocket au        ] => false ],
      [ %w[ Ddipocket softbank  ] => false ],
      [ %w[ Ddipocket vodafone  ] => false ],
      [ %w[ Ddipocket jphone    ] => false ],
      [ %w[ Ddipocket emobile   ] => false ],
      [ %w[ Ddipocket willcom   ] => true  ],
      [ %w[ Ddipocket ddipocket ] => true  ],
    ])
  end.run
end
