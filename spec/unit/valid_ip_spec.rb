require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Jpmobile::Mobile::valid_ip?' do
  Spec::Fixture::Base.new self, :remote_ip => :carrier do
    it 'should be return true if :remote_ip is in :carrier address' do |remote_ip, carrier|
      Jpmobile::Mobile.const_get(carrier).valid_ip?(remote_ip).should == true
    end

    set_fixtures([
      [ '210.153.84.1'    => :Docomo    ],
      [ '210.153.84.254'  => :Docomo    ],
      [ '210.230.128.225' => :Au        ],
      [ '210.230.128.238' => :Au        ],
      [ '123.108.236.1'   => :Softbank  ],
      [ '123.108.236.254' => :Softbank  ],
      [ '123.108.236.1'   => :Vodafone  ],
      [ '123.108.236.254' => :Vodafone  ],
      [ '123.108.236.1'   => :Jphone    ],
      [ '123.108.236.254' => :Jphone    ],
      [ '61.198.142.1'    => :Willcom   ],
      [ '61.198.142.254'  => :Willcom   ],
      [ '61.198.142.1'    => :Ddipocket ],
      [ '61.198.142.254'  => :Ddipocket ],
      [ '117.55.1.224'    => :Emobile   ],
      [ '117.55.1.254'    => :Emobile   ],
    ])
  end.run

  Spec::Fixture::Base.new self, :remote_ip => :carrier do
    it 'should not be return true if :remote_ip is in :carrier address' do |remote_ip, carrier|
      Jpmobile::Mobile.const_get(carrier).valid_ip?(remote_ip).should_not == true
    end

    set_fixtures([
      [ '127.0.0.1'       => :Docomo    ],
      [ '210.153.83.1'    => :Docomo    ],
      [ '210.153.83.254'  => :Docomo    ],
      [ '127.0.0.1'       => :Au        ],
      [ '210.169.41.1'    => :Au        ],
      [ '210.169.41.254'  => :Au        ],
      [ '127.0.0.1'       => :Softbank  ],
      [ '123.108.238.1'   => :Softbank  ],
      [ '123.108.238.254' => :Softbank  ],
      [ '127.0.0.1'       => :Vodafone  ],
      [ '123.108.238.1'   => :Vodafone  ],
      [ '123.108.238.254' => :Vodafone  ],
      [ '127.0.0.1'       => :Jphone    ],
      [ '123.108.238.1'   => :Jphone    ],
      [ '123.108.238.254' => :Jphone    ],
      [ '127.0.0.1'       => :Willcom  ],
      [ '61.198.144.1'    => :Willcom   ],
      [ '61.198.144.254'  => :Willcom   ],
      [ '127.0.0.1'       => :Ddipocket  ],
      [ '61.198.144.1'    => :Ddipocket ],
      [ '61.198.144.254'  => :Ddipocket ],
      [ '127.0.0.1'       => :Emobile  ],
      [ '117.55.1.223'    => :Emobile   ],
    ])
  end.run
end
