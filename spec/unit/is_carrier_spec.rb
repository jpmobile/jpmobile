require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Jpmobile::Mobile' do
  [
    [ %w[ Docomo docomo    ] , true ],
    [ %w[ Docomo au        ] , false ],
    [ %w[ Docomo softbank  ] , false ],
    [ %w[ Docomo vodafone  ] , false ],
    [ %w[ Docomo emobile   ] , false ],
    [ %w[ Docomo willcom   ] , false ],
    [ %w[ Docomo ddipocket ] , false ],

    [ %w[ Au docomo    ] , false ],
    [ %w[ Au au        ] , true ],
    [ %w[ Au softbank  ] , false ],
    [ %w[ Au vodafone  ] , false ],
    [ %w[ Au emobile   ] , false ],
    [ %w[ Au willcom   ] , false ],
    [ %w[ Au ddipocket ] , false ],

    [ %w[ Softbank docomo    ] , false ],
    [ %w[ Softbank au        ] , false ],
    [ %w[ Softbank softbank  ] , true ],
    [ %w[ Softbank vodafone  ] , false ],
    [ %w[ Softbank emobile   ] , false ],
    [ %w[ Softbank willcom   ] , false ],
    [ %w[ Softbank ddipocket ] , false ],

    [ %w[ Vodafone docomo    ] , false ],
    [ %w[ Vodafone au        ] , false ],
    [ %w[ Vodafone softbank  ] , true  ],
    [ %w[ Vodafone vodafone  ] , true  ],
    [ %w[ Vodafone emobile   ] , false ],
    [ %w[ Vodafone willcom   ] , false ],
    [ %w[ Vodafone ddipocket ] , false ],

    [ %w[ Emobile docomo    ] , false ],
    [ %w[ Emobile au        ] , false ],
    [ %w[ Emobile softbank  ] , false ],
    [ %w[ Emobile vodafone  ] , false ],
    [ %w[ Emobile emobile   ] , true  ],
    [ %w[ Emobile willcom   ] , false ],
    [ %w[ Emobile ddipocket ] , false ],

    [ %w[ Willcom docomo    ] , false ],
    [ %w[ Willcom au        ] , false ],
    [ %w[ Willcom softbank  ] , false ],
    [ %w[ Willcom vodafone  ] , false ],
    [ %w[ Willcom emobile   ] , false ],
    [ %w[ Willcom willcom   ] , true  ],
    [ %w[ Willcom ddipocket ] , false ],

    [ %w[ Ddipocket docomo    ] , false ],
    [ %w[ Ddipocket au        ] , false ],
    [ %w[ Ddipocket softbank  ] , false ],
    [ %w[ Ddipocket vodafone  ] , false ],
    [ %w[ Ddipocket emobile   ] , false ],
    [ %w[ Ddipocket willcom   ] , true  ],
    [ %w[ Ddipocket ddipocket ] , true  ],
  ].each do |carrier, expected|
    it "#{carrier.first}##{carrier.last}? should be return #{expected}" do
      Jpmobile::Mobile.const_get(carrier.first).new({}, {}).__send__("#{carrier.last}?").should == expected
    end
  end
end
