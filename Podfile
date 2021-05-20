#source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "10.0"

flutter_application_path = '../flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

def install_pods
    # 这里集成项目中用的三方库
    pod 'AFNetworking', '~> 3.2.1'
    pod 'SDWebImage', '~> 5.10.2'
end

target 'MyApp' do
    install_pods
    install_all_flutter_pods(flutter_application_path)
end
