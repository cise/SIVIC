namespace :setup do
  namespace :sar_data do
    desc "Load all basic data"
    task :all => [ :users, :spaces, :rooms, :roles ]

    desc "Load Basic data in test"
    task :test => "db:test:prepare" do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
      ActiveRecord::Schema.verbose = false
      Rake::Task["setup:sar_data:all"].invoke
    end

    desc "Load Users Data"
    task :users => :environment do

      puts "* Create COVI user \"COVI INNOVA RED\""
      c_innova = User.create :login => "covi_innova_red",
                       :email => 'covi@innova-red.net',
                       :password => "covi_innova_red",
                       :password_confirmation => "covi_innova_red"
      c_innova.activate
      c_innova.profile!.update_attribute(:full_name, "COVI INNOVA RED")

      puts "* Create COVI user \"COVI ADSIB\""
      c_adsib = User.create :login => "covi_adsib",
                       :email => 'covi@adsib.gob.bo',
                       :password => "covi_adsib",
                       :password_confirmation => "covi_adsib"
      c_adsib.activate
      c_adsib.profile!.update_attribute(:full_name, "COVI ADSIB")
      
      puts "* Create COVI user \"COVI RNP\""
      c_rnp = User.create :login => "covi_rnp",
                       :email => 'covi@rnp.br',
                       :password => "covi_rnp",
                       :password_confirmation => "covi_rnp"
      c_rnp.activate
      c_rnp.profile!.update_attribute(:full_name, "COVI RNP")
      
      puts "* Create COVI user \"COVI REUNA\""
      c_reuna = User.create :login => "covi_reuna",
                       :email => 'covi@reuna.cl',
                       :password => "covi_reuna",
                       :password_confirmation => "covi_reuna"
      c_reuna.activate
      c_reuna.profile!.update_attribute(:full_name, "COVI REUNA")

      puts "* Create COVI user \"COVI RENATA\""
      c_renata = User.create :login => "covi_renata",
                       :email => 'covi@renata.edu.co',
                       :password => "covi_renata",
                       :password_confirmation => "covi_renata"
      c_renata.activate
      c_renata.profile!.update_attribute(:full_name, "COVI RENATA")
      
      puts "* Create COVI user \"COVI CEDIA\""
      c_cedia = User.create :login => "covi_cedia",
                       :email => 'covi@cedia.org.ec',
                       :password => "covi_cedia",
                       :password_confirmation => "covi_cedia"
      c_cedia.activate
      c_cedia.profile!.update_attribute(:full_name, "COVI CEDIA")
      

      puts "* Create COVI user \"COVI RAICES\""
      c_raices = User.create :login => "covi_raices",
                       :email => 'covi@raices.org.sv',
                       :password => "covi_raices",
                       :password_confirmation => "covi_raices"
      c_raices.activate
      c_raices.profile!.update_attribute(:full_name, "COVI RAICES")

      puts "* Create COVI user \"COVI RAGIE\""
      c_ragie = User.create :login => "covi_ragie",
                       :email => 'covi@ragie.org.gt',
                       :password => "covi_ragie",
                       :password_confirmation => "covi_ragie"
      c_ragie.activate
      c_ragie.profile!.update_attribute(:full_name, "COVI RAGIE")
      
      puts "* Create COVI user \"COVI CUDI\""
      c_cudi = User.create :login => "covi_cudi",
                       :email => 'covi@cudi.edu.mx',
                       :password => "covi_cudi",
                       :password_confirmation => "covi_cudi"
      c_cudi.activate
      c_cudi.profile!.update_attribute(:full_name, "COVI CUDI")
      
      puts "* Create COVI user \"COVI RAAP\""
      c_raap = User.create :login => "covi_raap",
                       :email => 'covi@raap.org.pe',
                       :password => "covi_raap",
                       :password_confirmation => "covi_raap"
      c_raap.activate
      c_raap.profile!.update_attribute(:full_name, "COVI RAAP")

      puts "* Create COVI user \"COVI RAU\""
      c_rau = User.create :login => "covi_rau",
                       :email => 'covi@rau.edu.uy',
                       :password => "covi_rau",
                       :password_confirmation => "covi_rau"
      c_rau.activate
      c_rau.profile!.update_attribute(:full_name, "COVI RAU")
      
      puts "* Create COVI user \"COVI CENIT\""
      c_cenit = User.create :login => "covi_cenit",
                       :email => 'covi@cenit.gob.ve',
                       :password => "covi_cenit",
                       :password_confirmation => "covi_cenit"
      c_cenit.activate
      c_cenit.profile!.update_attribute(:full_name, "COVI CENIT")

      puts "* Create COVI user \"COVI CONARE\""
      c_conare = User.create :login => "covi_concara",
                       :email => 'covi@conare.cr',
                       :password => "covi_conare",
                       :password_confirmation => "covi_conare"
      c_conare.activate
      c_conare.profile!.update_attribute(:full_name, "COVI CONARE")
      
      puts "* Create COVI user \"COVI REDCYT\""
      c_redcyt = User.create :login => "covi_redcyt",
                       :email => 'covi@redcyt.pa',
                       :password => "covi_redcyt",
                       :password_confirmation => "covi_redcyt"
      c_redcyt.activate
      c_redcyt.profile!.update_attribute(:full_name, "COVI REDCYT")

      puts "* Create COVI user \"COVI ESPOL\""
      c_espol = User.create :login => "covi_espol",
                       :email => 'covi@espol.edu.ec',
                       :password => "covi_espol",
                       :password_confirmation => "covi_espol"
      c_espol.activate
      c_espol.profile!.update_attribute(:full_name, "COVI ESPOL")

      puts "* Create COVI user \"COVI UNEMI\""
      c_unemi = User.create :login => "covi_covi",
                       :email => 'covi@unemi.edu.ec',
                       :password => "covi_unemi",
                       :password_confirmation => "covi_unemi"
      c_unemi.activate
      c_unemi.profile!.update_attribute(:full_name, "COVI UNEMI")

      puts "* Create COVI user \"COVI UTPL\""
      c_utpl = User.create :login => "covi_utpl",
                       :email => 'covi@utpl.edu.ec',
                       :password => "covi_utpl",
                       :password_confirmation => "covi_utpl"
      c_utpl.activate
      c_utpl.profile!.update_attribute(:full_name, "COVI UNC")

      puts "* Create COVI user \"COVI UNC\""
      c_unc = User.create :login => "covi_unc",
                       :email => 'covi@unc.edu.co',
                       :password => "covi_unc",
                       :password_confirmation => "covi_unc"
      c_unc.activate
      c_unc.profile!.update_attribute(:full_name, "COVI UNC")

      puts "* Create Organizer user \"organizer\""
      ou = User.create :login => "organizer",
                       :email => 'rebelk28@hotmail.com',
                       :password => "organizer",
                       :password_confirmation => "organizer"
      ou.activate
      ou.profile!.update_attribute(:full_name, "Organizer user")

      puts "* Create Invited user \"invited\""
      iu = User.create :login => "invited",
                       :email => 'kleber.bano@gmail.com',
                       :password => "invited",
                       :password_confirmation => "invited"
      iu.activate
      iu.profile!.update_attribute(:full_name, "Invited user")
    end

    desc "Load Spaces Data"
    task :spaces => :environment do
      puts "* Clear Spaces"
      clara_space = Space.find_by_name("Red CLARA")
      
      if clara_space != nil
        Space.delete_all("id != " + clara_space.id.to_s)
      end
      
      puts "* Create Spaces for institutions"
#      clara = Space.create :name => "CLARA",
#                :description => "La visión de CLARA es ser un sistema latinoamericano de colaboración mediante redes avanzadas de telecomunicaciones para la investigación, la innovación y la educación.",
#                :public => true,
#                :repository => true,
#                :default_logo => "models/front/clara.gif",
#                :skin => "default"
      innovared = Space.create :name => "INNOVA RED",
                :description => " Innova|Red es un proyecto de Innova-T, una ONG fundada por el CONICET. Es la red académica nacional argentina cuya razón de ser es proveer a la comunidad educativa y de investigación de los medios más modernos para llevar a cabo las tareas que requieran transmisión de datos.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/innovared.png",
                :country => "AR",
                :parent_id => clara_space.id,
                :skin => "default"
      
      adsib = Space.create :name => "ADSIB",
                :description => "La ADSIB es la encargada de proponer políticas, implementar estrategias y coordinar acciones orientadas a reducir la brecha digital en el país, a través del impulso de las Tecnologías de la Información y Comunicación en todos sus ámbitos, teniendo como principal misión favorecer relaciones del Gobierno con la Sociedad, mediante el uso de tecnologías adecuadas.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/adsib.png",
                :country => "BO",
                :parent_id => clara_space.id,
                :skin => "default"
      
      rnp = Space.create :name => "RNP",                        
                :description => "La Rede Nacional de Ensino e Pesquisa (RNP – Red Nacional de Enseñanza e Pesquisa) promueve el desarrollo de tecnologías en el área de redes y aplicaciones innovadoras en Brasil, apoyando la utilización de redes Internet como cooperadoras del progreso de la ciencia y de la educación en general.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/rnp.png",
                :country => "BR",
                :parent_id => clara_space.id,
                :skin => "default"
      
      reuna = Space.create :name => "REUNA",
                :description => "La Corporación REUNA es una iniciativa de colaboración que cuenta con la única infraestructura tecnológica de red de naturaleza académica, dedicada a la investigación y al desarrollo en Chile.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/reuna.png",
                :country => "CL",
                :parent_id => clara_space.id,
                :skin => "default"
      
      renata = Space.create :name => "RENATA",
                :description => "RENATA es la red de tecnología avanzada que conecta, comunica y propicia la colaboración entre la comunidad académica y científica de Colombia con la comunidad académica internacional y los centros de investigación más desarrollados del mundo.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/renata.png",
                :country => "CO",
                :parent_id => clara_space.id,
                :skin => "default"
      
      cedia = Space.create :name => "CEDIA",
                :description => "Promover, coordinar y desarrollar redes avanzadas de informática y telecomunicaciones para impulsar, en forma innovadora, la investigación científica, tecnológica y la educación en el Ecuador.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/cedia.png",
                :country => "EC",
                :parent_id => clara_space.id,
                :skin => "default"
      
      raices = Space.create :name => "RAICES",
                :description => "RAICES es la Red Nacional de Investigación y Educación de El Salvador (NREN) y es miembro fundador de CLARA (Cooperación LatinoAmericana de Redes Avanzadas). Es socio local de DANTE (Delivering Advanced Network To Europe) y de CLARA para el Proyecto ALICE (América Latina Interconecta con Europa) y su continuación, ALICE2.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/raices.png",
                :country => "SV",
                :parent_id => clara_space.id,
                :skin => "default"
      
      ragie = Space.create :name => "RAGIE",
                :description => "La Red Avanzada Guatemalteca para la Investigación y Educación es una asociación civil sin fines de lucro constituida por Universidades, Institutos de Investigación y otras instituciones Guatemaltecas dedicadas a la investigación y educación, que desarrolla proyectos para el logro de sus fines a través de redes y la explotación de las telecomunicaciones.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/ragie.png",
                :country => "GT",
                :parent_id => clara_space.id,
                :skin => "default"
      
      cudi = Space.create :name => "CUDI",
                :description => "La Corporación Universitaria para el Desarrollo de Internet (CUDI), es una asociación civil sin fines de lucro que gestiona la Red Nacional de Educación e Investigación para promover el desarrollo de nuestro país y aumentar la sinergia entre sus integrantes. Fue fundada en abril de 1999.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/cudi.png",
                :country => "MX",
                :parent_id => clara_space.id,
                :skin => "default"
      
      raap = Space.create :name => "RAAP",
                :description => "El desafío actual del Perú consiste en crear y consolidar una infraestructura de redes avanzadas de investigación y educación a niveles regional y nacional. Un punto de partida de este esfuerzo lo constituye desde Abril del 2003, la red nacional de investigación y educación (NREN) Red Académica Peruana - RAAP.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/raap.png",
                :country => "PE",
                :parent_id => clara_space.id,
                :skin => "default"
      
      rau = Space.create :name => "RAU",
                :description => "La Red Académica Uruguaya (RAU) es un emprendimiento de la Universidad de la República, administrado por el Servicio Central de Informática Universitario (SeCIU) que opera desde el año 1988.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/rau.png",
                :country => "UY",
                :parent_id => clara_space.id,
                :skin => "default"
      
      cenit = Space.create :name => "CENIT",
                :description => "El Centro Nacional de Innovación Tecnológica (Cenit) es una fundación adscrita al Ministerio del Poder Popular para Ciencia, Tecnología e Industrias Intermedias (Mppctii) que tiene como objeto propiciar la investigación, el desarrollo y la innovación en el área de las Tecnologías de Información y Comunicación (TIC), de acuerdo con las necesidades del modelo socioproductivo del país.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/reacciun.png",
                :country => "VE",
                :parent_id => clara_space.id,
                :skin => "default"
      
      conare = Space.create :name => "CONARE",
                :description => "CONARE Costa Rica",
                :public => true,
                :repository => true,
                :default_logo => "models/front/conare.png",
                :country => "CR",
                :parent_id => clara_space.id,
                :skin => "default"
      
      redcyt = Space.create :name => "REDCYT",
                :description => "RedCyT Panamá",
                :public => true,
                :repository => true,
                :default_logo => "models/front/redcyt.png",
                :country => "PA",
                :parent_id => clara_space.id,
                :skin => "default"
      
      espol = Space.create :name => "ESPOL",
                :description => "Formar profesionales de excelencia, líderes emprendedores, con sólidos valores morales y éticos que contribuyan al desarrollo del país, para mejorarlo en lo social, económico, ambiental y político. Hacer investigación, transferencia de tecnología y extensión de calidad para servir a la sociedad.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/espol.png",
                :country => "EC",
                :parent_id => cedia.id,
                :skin => "default"

      unemi = Space.create :name => "UNEMI",
                :description => "La Universidad Estatal de Milagro es una institución dedicada a la formación del talento y los valores humanos, generadora de alternativas de solución a problemas, mediante la gestión sostenida de los recursos, en colaboración con organismos del estado y la sociedad, para mejorar la calidad de vida de su entorno.",
                :public => true,
                :repository => true,
                :default_logo => "models/front/unemi.png",
                :country => "EC",
                :parent_id => cedia.id,
                :skin => "default"

      utpl = Space.create :name => "UPTL",
               :description => "La vida dentro de nuestra Universidad se encamina a llevar a plenitud los ideales que dieron origen a las universidades, teniendo como visión el \"Humanismo Cristiano\", nuestra misión es: \"Buscar la verdad y formar al hombre, a través de la ciencia, para que sirva a la sociedad\"",
               :public => true,
               :repository => true,
               :default_logo => "models/front/utpl.jpg",
               :country => "EC",
               :parent_id => cedia.id,
               :skin => "default"

      unc = Space.create :name => "Universidad Nacional de Colombia",
              :description => "Como Universidad de la Nación fomenta el acceso con equidad al sistema educativo colombiano, provee la mayor oferta de programas académicos, forma profesionales competentes y socialmente responsables. Contribuye a la elaboración y resignificación del proyecto de Nación, estudia y enriquece el patrimonio cultural, natural y ambiental del país. Como tal lo asesora en los órdenes científico, tecnológico, cultural y artístico con autonomía académica e investigativa.",
              :public => true,
              :repository => true,
              :default_logo => "models/front/unc.png",
              :country => "CO",
              :parent_id => renata.id,
              :skin => "default"

      upa = Space.create :name => "Universidad de Panama",
              :description => "Sus objetivos fundamentales contenidos en su carta de fundación comprenden el desarrollo de la docencia, la investigación y la extensión y en ella se estimula y promueve la producción intelectual y el cultivo de nuestras costumbres y tradiciones.",
              :public => true,
              :repository => true,
              :default_logo => "models/front/upa.png",
              :country => "PA",
              :parent_id => redcyt.id,
              :skin => "default"
    end

    desc "Load Romms Data"
    task :rooms => :environment do
      puts "* Clear Rooms"
      Room.destroy_all
      
      puts "* Create Rooms for institutions"
      espol = Space.find(:first, :conditions => ["name = 'ESPOL'"])
      espol_cti = Room.create :name => "Aula Satelital ESPOL",
                    :description => "Aula Satelital ESPOL",
                    :country => "Ecuador",
                    :city => "Guayaquil",
                    :location => "Km. 30.5 vía Perimetral. Campus Gustavo Galindo Velasco",
                    :service_type => Room::SERVICE_TYPE_NOT_CERTIFIED,
                    :ip_address => "127.0.0.1",
                    :uri => "http://127.0.0.1",
                    :lng => -2.151781,
                    :lat => -79.956539,
                    :space_id => espol.id
      
      espol_cise = Room.create :name => "Aula Tecnologica ESPOL",
                     :description => "Aula Tecnologica ESPOL",
                     :country => "Ecuador",
                     :city => "Guayaquil",
                     :location => "Km. 30.5 vía Perimetral. Campus Gustavo Galindo Velasco",
                     :service_type => Room::SERVICE_TYPE_NOT_CERTIFIED,
                     :ip_address => "127.0.0.1",
                     :uri => "http://127.0.0.1",
                     :lng => -2.151781,
                     :lat => -79.956539,
                     :space_id => espol.id
                     
      unc = Space.find(:first, :conditions => ["name = 'Universidad Nacional de Colombia'"])
      unc_aula = Room.create :name => "Aula Video Conferencia",
                   :description => "Aula Video Conferencia",
                   :country => "Colombia",
                   :city => "Medellin",
                   :service_type => Room::SERVICE_TYPE_NOT_CERTIFIED,
                   :ip_address => "127.0.0.1",
                   :uri => "http://127.0.0.1",
                   :space_id => unc.id
      
      utpl = Space.find(:first, :conditions => ["name = 'UPTL'"])
      utpl_aula = Room.create :name => "Aula Satelital UTPL",
                    :description => "Aula Satelital",
                    :country => "Ecuador",
                    :city => "Loja",
                    :service_type => Room::SERVICE_TYPE_NOT_CERTIFIED,
                    :ip_address => "127.0.0.1",
                    :uri => "http://127.0.0.1",
                    :space_id => utpl.id
      
      upa = Space.find(:first, :conditions => ["name = 'Universidad de Panama'"])
      upa_aula = Room.create :name => "Aula de Video Conferencia UP",
                   :description => "Aula de Video Conferencia UP",
                   :country => "Panama",
                   :city => "Ciudad de Panama",
                   :service_type => Room::SERVICE_TYPE_NOT_CERTIFIED,
                   :ip_address => "127.0.0.1",
                   :uri => "http://127.0.0.1",
                   :space_id => upa.id
    end
  
    desc "Load Spaces Data"
    task :permissions => :environment do
      puts "* Create Permissions"

      # Permissions without objective
      %w( create read update delete translate ).each do |action|
        Permission.find_or_create_by_action_and_objective action, nil
      end

      # Permissions applied to Content and Performance
      %w( create read update delete ).each do |action|
        %w( content performance ).each do |objective|
          Permission.find_or_create_by_action_and_objective action, objective
        end
      end
      
      Permission.find_or_create_by_action_and_objective "update", "attachment"

      # Permission applied to Group
      Permission.find_or_create_by_action_and_objective "manage", "group"
      
      # Permission applied to Room
      Permission.find_or_create_by_action_and_objective "manage", "room"
    end

    desc "Load Roles Data"
    task :roles => :permissions do
      puts "* Create SAR Roles"

      vnoc_role = Role.find_or_create_by_name_and_stage_type "VNOC", "Room"
      vnoc_role.permissions << Permission.find_by_action_and_objective('read', nil)
      vnoc_role.permissions << Permission.find_by_action_and_objective('update', nil)
      vnoc_role.permissions << Permission.find_by_action_and_objective('delete', nil)
      vnoc_role.permissions << Permission.find_by_action_and_objective('create', 'content')
      vnoc_role.permissions << Permission.find_by_action_and_objective('read', 'content')
      vnoc_role.permissions << Permission.find_by_action_and_objective('update', 'content')
      vnoc_role.permissions << Permission.find_by_action_and_objective('delete', 'content')
      vnoc_role.permissions << Permission.find_by_action_and_objective('create', 'performance')
      vnoc_role.permissions << Permission.find_by_action_and_objective('read', 'performance')
      vnoc_role.permissions << Permission.find_by_action_and_objective('update', 'performance')
      vnoc_role.permissions << Permission.find_by_action_and_objective('delete', 'performance')
      vnoc_role.permissions << Permission.find_by_action_and_objective('manage', 'group')

      covi_role = Role.find_or_create_by_name_and_stage_type "COVI", "Room"
      covi_role.permissions << Permission.find_by_action_and_objective('read', nil)
      covi_role.permissions << Permission.find_by_action_and_objective('create', 'content')
      covi_role.permissions << Permission.find_by_action_and_objective('read', 'content')
      covi_role.permissions << Permission.find_by_action_and_objective('update', 'content')
      covi_role.permissions << Permission.find_by_action_and_objective('delete', 'content')
      covi_role.permissions << Permission.find_by_action_and_objective('manage', 'group')

      authorizer_role = Role.find_or_create_by_name_and_stage_type "Authorizer", "Reservation"
      authorizer_role.permissions << Permission.find_by_action_and_objective('read', nil)
      authorizer_role.permissions << Permission.find_by_action_and_objective('update', nil)
      authorizer_role.permissions << Permission.find_by_action_and_objective('create', 'content')
      authorizer_role.permissions << Permission.find_by_action_and_objective('read', 'content')
      authorizer_role.permissions << Permission.find_by_action_and_objective('update', 'content')
      authorizer_role.permissions << Permission.find_by_action_and_objective('delete', 'content')
      authorizer_role.permissions << Permission.find_by_action_and_objective('manage', 'group')

      organizer_role = Role.find_or_create_by_name_and_stage_type "Organizer", "Reservation"
      organizer_role.permissions << Permission.find_by_action_and_objective('create', nil)
      organizer_role.permissions << Permission.find_by_action_and_objective('read', nil)
      organizer_role.permissions << Permission.find_by_action_and_objective('update', nil)
      organizer_role.permissions << Permission.find_by_action_and_objective('create', 'content')
      organizer_role.permissions << Permission.find_by_action_and_objective('read', 'content')
      organizer_role.permissions << Permission.find_by_action_and_objective('update', 'content')
      organizer_role.permissions << Permission.find_by_action_and_objective('delete', 'content')

      invitedvc_role = Role.find_or_create_by_name_and_stage_type "Invitedvc", "Reservation"
      invitedvc_role.permissions << Permission.find_by_action_and_objective('read', nil)
      invitedvc_role.permissions << Permission.find_by_action_and_objective('read', 'content')
      invitedvc_role.permissions << Permission.find_by_action_and_objective('read', 'performance')

      puts "* Create SAR Performances"
      require 'populator'
      
      user = User.find(:first, :conditions => ["login = 'vnoc'"] )

      # usuario VNOC tiene rol VNOC en todas las salas 
      Room.all.each do |room|
        Performance.create :stage_id => room.id,
                           :stage_type => 'Room',
                           :role_id => vnoc_role.id,
                           :agent_id => user.id,
                           :agent_type => 'User'


#        space.groups.each do |group|
#          space.users.each do |user|
#            next if user.is_a?(SingularAgent)
#            group.users << user if rand > 0.7
#          end
#        end
      end
      
      admin_space_role = Role.find_or_create_by_name_and_stage_type "Admin", "Space"
      Space.all.each do |space|
        Performance.create :stage_id => space.id,
                           :stage_type => 'Space',
                           :role_id => admin_space_role.id,
                           :agent_id => user.id,
                           :agent_type => 'User'
      end

      user_space_role = Role.find_or_create_by_name_and_stage_type "Admin", "Space"
      Space.all.each do |space|
        user = User.find_by_login('covi_' + space.name.downcase.tr(" ", "_"))
        if user != nil
          Performance.create :stage_id => space.id,
                             :stage_type => 'Space',
                             :role_id => user_space_role.id,
                             :agent_id => user.id,
                             :agent_type => 'User'

#          space.rooms.each do |room|
#            Performance.create :stage_id => room.id,
#                             :stage_type => 'Room',
#                             :role_id => covi_role.id,
#                             :agent_id => user.id,
#                             :agent_type => 'User'
#          end
        end
      end                           
    
    end
  end
end
