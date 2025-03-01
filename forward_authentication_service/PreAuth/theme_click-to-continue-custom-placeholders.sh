#!/bin/sh
#Copyright (C) The openNDS Contributors 2004-2022
#Copyright (C) BlueWave Projects and Services 2015-2024
#This software is released under the GNU GPL license.
#
# Warning - shebang sh is for compatibliity with busybox ash (eg on OpenWrt)
# This is changed to bash automatically by Makefile for generic Linux
#

# Title of this theme:
title="theme_click-to-continue-custom-placeholders"

# functions:

download_data_files() {
	# The list of files to be downloaded is defined in $ndscustomfiles ( see near the end of this file )
	# The source of the files is defined in the openNDS config

	for nameoffile in $ndscustomfiles; do
		get_data_file "$nameoffile"
	done
}

download_image_files() {
	# The list of images to be downloaded is defined in $ndscustomimages ( see near the end of this file )
	# The source of the images is defined in the openNDS config

	for nameofimage in $ndscustomimages; do
		get_image_file "$nameofimage"
	done
}

generate_splash_sequence() {
	click_to_continue
}

header() {
# Define a common header html for every page served
	gatewayurl=$(printf "${gatewayurl//%/\\x}")
	htmlentitydecode "$logo_message"
	urldecode "$entitydecoded"
	logo_message="$urldecoded"

	echo "<!DOCTYPE html>
		<html>
		<head>
		<meta http-equiv=\"Cache-Control\" content=\"no-cache, no-store, must-revalidate\">
		<meta http-equiv=\"Pragma\" content=\"no-cache\">
		<meta http-equiv=\"Expires\" content=\"0\">
		<meta charset=\"utf-8\">
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
		<link rel=\"shortcut icon\" href=\"$gatewayurl/ndsremote/banner1.jpg\" type=\"image/x-icon\">
		<link rel=\"stylesheet\" type=\"text/css\" href=\"$gatewayurl/splash.css\">
		<title>$gatewayname</title>
		</head>
		<body>
		<div class=\"offset\">
		<med-blue>
			$gatewayname <br>
		</med-blue>
		<div class=\"insert\" style=\"max-width:100%;\">
		<img src=\"$gatewayurl""$banner1\" alt=\"Placeholder: Logo.\"><br>
		<b>$logo_message</b><br>
	"
}

footer() {
	# Define a common footer html for every page served
	year=$(date +'%Y')
	echo "
		<hr>
		<div style=\"font-size:0.5em; max-width:100% display:flex; justify-content: center; flex-direction: column;\">
			<br>
			<img style=\"height:60px; width:80%;\" src=\"$gatewayurl""$banner2\" alt=\"Splash Page: For access to the Internet.\">
			&copy; Portal: NBN Telecom - 2005 - $year<br>
			<br>
			Portal Version: $version
			<br>
			<p style=\"font-size:0.3em \"> Developers: Wellyson Yago Monteiro da Silva - Richard de Sousa Oliveira </p>
			<br><br><br><br>
		</div>
		</div>
		</div>
		</body>
		</html>
	"

	exit 0
}

click_to_continue() {
	# This is the simple click to continue splash page with no client validation.
	# The client is however required to accept the terms of service.

	if [ "$continue" = "clicked" ]; then
		thankyou_page
		footer
	fi

	continue_form
	footer
}

continue_form() {
	# Define a click to Continue form

	htmlentitydecode "$banner1_message"
	urldecode "$entitydecoded"
	banner1_message="$urldecoded"

	echo "
		<big-red>Bem Vindo!</big-red><br>
		<img style=\"width:30%; max-width: 100%;\" src=\"$gatewayurl""$banner1\" alt=\"Placeholder: Banner1.\"><br>
		<b>$banner1_message</b><hr>
		<med-blue>Você está conectado em: <br>$client_zone</med-blue><br>
		<italic-black>
			Para acessar a internet você precisa aceitar os Termos de Serviço.
		</italic-black>
		<hr>
		<form action=\"/opennds_preauth/\" method=\"get\">
			<input type=\"hidden\" name=\"fas\" value=\"$fas\">
			<input type=\"hidden\" name=\"continue\" value=\"clicked\">
			$custom_inputs
			<input type=\"submit\" value=\"Aceitar Termos de Serviços\" >
		</form>
		<br>
	"

	read_terms
	footer
}

thankyou_page () {
	# If we got here, we have both the username and emailaddress fields as completed on the login page on the client,
	# or Continue has been clicked on the "Click to Continue" page
	# No further validation is required so we can grant access to the client. The token is not actually required.

	# We now output the "Thankyou page" with a "Continue" button.

	# This is the place to include information or advertising on this page,
	# as this page will stay open until the client user taps or clicks "Continue"

	# Be aware that many devices will close the login browser as soon as
	# the client user continues, so now is the time to deliver your message.

	htmlentitydecode "$banner2_message"
	urldecode "$entitydecoded"
	banner2_message="$urldecoded"

	echo "
		<big-red>
			Obrigado por usar nossos serviços.<br>Por favor click Continue para acessar.
		</big-red>
		<br>
		<b>Bem Vindo !</b>
		<br>
		<med-blue>Você está conectado em $client_zone</med-blue><br>
	"

	# Add your message here:
	# You could retrieve text or images from a remote server using wget or curl
	# as this router has Internet access whilst the client device does not (yet).

	if [ -e "$mountpoint/ndsdata/advert1.htm" ]; then
		advert1=$(cat "$mountpoint/ndsdata/advert1.htm")
	else
		advert1="Sua notícia ou publicidade pode estar aqui. Entre em contato com os proprietários deste Hotspot para saber como!"
	fi

	echo "
		<br>
		<italic-black>
			<img style=\"width:50%; max-width: 100%;\" src=\"$gatewayurl""$banner1\" alt=\"Placeholder: Banner2.\"><br>
			<b>Fust Escolas conectadas</b><br>
			$advert1
			<hr>
		</italic-black>
	"

	if [ -z "$custom" ]; then
		customhtml=""
	else
		customhtml="<input type=\"hidden\" name=\"custom\" value=\"$custom\">"
	fi

	# Continue to the landing page, the client is authenticated there
	echo "
		<form action=\"/opennds_preauth/\" method=\"get\">
			<input type=\"hidden\" name=\"fas\" value=\"$fas\">
			$customhtml
			$custom_passthrough
			<input type=\"hidden\" name=\"landing\" value=\"yes\">
			<input type=\"submit\" value=\"Continue\" >
		</form>
		<br>
	"

	# Serve the rest of the page:
	read_terms
	footer
}

landing_page() {
	originurl=$(printf "${originurl//%/\\x}")
	gatewayurl=$(printf "${gatewayurl//%/\\x}")

	configure_log_location
	. $mountpoint/ndscids/ndsinfo

	# authenticate and write to the log - returns with $ndsstatus set
	auth_log

	# output the landing page - note many CPD implementations will close as soon as Internet access is detected
	# The client may not see this page, or only see it briefly

	htmlentitydecode "$banner3_message"
	urldecode "$entitydecoded"
	banner3_message="$urldecoded"

	auth_success="
		<p>
			<big-red>
				Você está agora logado e recebeu acesso à Internet.
			</big-red>
			<hr>
			<img style=\"width:30%; max-width: 100%;\" src=\"$gatewayurl""$banner1\" alt=\"Placeholder: Banner3.\"><br>
			<b>$banner1_message</b><br>
		</p>
		<hr>
		<p>
			<italic-black>
				Você pode usar seu navegador, e-mail e outros aplicativos de rede normalmente.
			</italic-black>
			<hr>
			Clique ou toque em Continuar para exibir o status da sua conta.
		</p>
		<form>
			<input type=\"button\" VALUE=\"Continue\" onClick=\"location.href='$gatewayurl'\" >
		</form>
		<hr>
	"
	auth_fail="
		<p>
			<big-red>
				Algo deu errado e você não conseguiu fazer login.
			</big-red>
			<hr>
			<img style=\"width:30%; max-width: 100%;\" src=\"$gatewayurl""$banner1\" alt=\"Placeholder: Banner1.\"><br>
			<b>$banner1_message</b><br>
		</p>

		<p>
			<italic-black>
				Sua tentativa de login provavelmente expirou.
			</italic-black>
		</p>
		<p>
			<br>
			Clique ou toque em Continuar para tentar novamente.
		</p>
		<form>
			<input type=\"button\" VALUE=\"Continue\" onClick=\"location.href='http://$gatewayfqdn'\" >
		</form>
		<hr>
	"

	if [ "$ndsstatus" = "authenticated" ]; then
		echo "$auth_success"
	else
		echo "$auth_fail"
	fi

	read_terms
	footer
}

read_terms() {
	#terms of service button
	echo "
		<form action=\"/opennds_preauth/\" method=\"get\">
			<input type=\"hidden\" name=\"fas\" value=\"$fas\">
			$custom_passthrough
			<input type=\"hidden\" name=\"terms\" value=\"yes\">
			<input type=\"submit\" value=\"Ler Termos de Serviço   \" >
		</form>
	"
}

display_terms() {
	# This is the all important "Terms of service"
	# Edit this long winded generic version to suit your requirements.
	####
	# WARNING #
	# It is your responsibility to ensure these "Terms of Service" are compliant with the REGULATIONS and LAWS of your Country or State.
	# In most locations, a Privacy Statement is an essential part of the Terms of Service.
	####

	#Privacy
	echo "
		<b style=\"color:red;\">Privacidade.</b><br>

		<div style=\"text-align: justify; line-height: 1.5; \"> 

		<b>
			Ao fazer login no sistema, você concede permissão para que este sistema armazene quaisquer dados que você fornecer para fins de login, juntamente com os parâmetros de rede do seu dispositivo que o sistema necessita para funcionar.
			Todas as informações são armazenadas para sua conveniência e para a proteção tanto sua quanto nossa.
			Todas as informações coletadas por este sistema são armazenadas de forma segura e não são acessíveis por terceiros.
			Em troca, concedemos a você acesso gratuito à Internet.
		</b>
		
		</div>
		<hr>
	"

	# Terms of Service
	echo "
		<b style=\"color:red;\">Termo de Aceite para Utilização do Serviço Wi-Fi.</b> <br>
		
		<div style=\"text-align: justify; line-height: 1.5; \"> 

		<p>O serviço Wi-Fi é provido e de responsabilidade da Associação Administradora da Conectividade de Escolas EACE, inscrita no CNPJ/MF sob o N. 45.726.363/0001-47.

		Este aviso de privacidade possui o objetivo de apresentar como a EACE realiza o tratamento de dados pessoais coletados pelo serviço Wi-Fi na instituição, de acordo com as diretrizes da Lei Federal 13.709/18 - Lei Geral de Proteção de Dados.

		Tratamentos de Dados Pessoais Realizados pelo Serviço Wi-Fi

		Para que você possa acessar a internet através do serviço Wi-Fi, são coletados alguns dados pessoais para fins de registros de conexão e outros requisitos previstos no Marco Civil da Internet (Lei 12.965/2014) e demais legislações 
		
		brasileiras aplicáveis. 
		
		Alguns desses dados também podem ser utilizados com o propósito de gerar estatísticas de operação e uso do serviço de forma anonimizada.

		São coletados dados como nome, e-mail, endereço IP da conexão, tipo, sistema operacional e endereço físico do dispositivo móvel, rede sem fio utilizada, data, hora, destino e duração das conexões.

		A EACE não realiza o compartilhamento dos dados pessoais com terceiros, contudo, em casos que seja destinatária de requisições de informações solicitadas por autoridades competentes, os dados pessoais 
		
		poderão ser compartilhados com estes órgãos, com fins de cumprimento de medidas legais ou regulatórias.</p><hr>
		
		</div>
		
		<b>Ao prosseguir, declaro estar ciente das condições de tratamento dos meus dados pessoais, conforme descrito no aviso de privacidade do serviço Wi-Fi na instituição.</b>

		<form>
			<input type=\"button\" VALUE=\"Continue\" onClick=\"history.go(-1);return true;\">
		</form>
	"

	# Proper Use
	echo "
		<hr> **Uso Adequado** 
		<div style=\"text-align: justify; line-height: 1.5; \"> 

		<p> Este Hotspot fornece uma rede sem fio que permite a conexão à Internet. 
		<b>O uso desta conexão à Internet é fornecido em troca da sua TOTAL aceitação destes Termos de Serviço.</b> ]
		</p> 
		<p> <b>Você concorda</b> 
		que é responsável por adotar medidas de segurança adequadas para o uso pretendido do Serviço. Por exemplo, você assume total responsabilidade por tomar medidas adequadas para proteger seus dados contra perdas. 
		</p> 
		<p> 
		Embora o Hotspot utilize esforços comercialmente razoáveis para fornecer um serviço seguro, a eficácia dessas medidas não pode ser garantida. 
		</p> 
		<p> 
		<b>Você pode</b> 
		usar a tecnologia fornecida por este Hotspot exclusivamente para o uso do Serviço conforme descrito aqui. Você deve notificar imediatamente o Proprietário sobre qualquer uso não autorizado do Serviço ou qualquer outra violação de segurança. <br><br> 
		Cada vez que você acessar o Hotspot, será atribuído um endereço IP, que pode mudar. <br> 
		<b>Você não deve</b> 
		programar qualquer outro endereço IP ou MAC em seu dispositivo para acessar o Hotspot. Você também não pode usar o Serviço para qualquer outro fim, incluindo revender qualquer aspecto do Serviço. Outros exemplos de atividades indevidas incluem, entre outros: 
		</p> 
		<ol> 
		<li>Baixar ou enviar grandes volumes de dados que degradem significativamente o desempenho do Serviço para outros usuários por um período prolongado;
		</li> 
		<li>Tentar violar a segurança, acessar, adulterar ou usar qualquer área não autorizada do Serviço;</li> <li>Remover quaisquer avisos de direitos autorais, marcas registradas ou outros direitos de propriedade contidos no Serviço;
		</li> 
		<li>Tentar coletar ou manter informações sobre outros usuários do Serviço (incluindo nomes de usuário e/ou endereços de e-mail) ou terceiros para fins não autorizados;
		</li> 
		<li>Fazer login no Serviço sob falsas pretensões ou de forma fraudulenta;
		</li> 
		<li>Criar ou transmitir comunicações eletrônicas indesejadas, como SPAM ou correntes, para outros usuários ou interferir no uso do serviço por outros usuários;
		</li> 
		<li>Transmitir vírus, worms, defeitos, Cavalos de Troia ou outros elementos de natureza destrutiva;
		</li> 
		<li>Usar o Serviço para qualquer finalidade ilegal, assediosa, abusiva, criminosa ou fraudulenta.
		</li> 
		</ol>

		</div>
	"

	# Content Disclaimer
	echo "
		<hr> **Isenção de Responsabilidade sobre Conteúdo** 
		<div style=\"text-align: justify; line-height: 1.5; \"> 

		<p> Os Proprietários do Hotspot não controlam e não são responsáveis por dados, conteúdos, serviços ou produtos acessados ou baixados por meio do Serviço. Os Proprietários podem, mas não são obrigados a, bloquear transmissões de dados para proteger a si mesmos e ao público. 
		</p>
		
		Os Proprietários, seus fornecedores e licenciadores rejeitam expressamente, na máxima extensão permitida por lei,
		
		todas as garantias expressas, implícitas e legais, incluindo, sem limitação, garantias de comercialização
		
		ou adequação para um propósito específico.
		
		<br><br>
		Os Proprietários, seus fornecedores e licenciadores rejeitam expressamente, na máxima extensão permitida por lei,
		qualquer responsabilidade por infração de direitos de propriedade e/ou violação de direitos autorais por qualquer usuário do sistema.
		Os detalhes de login e as identidades dos dispositivos podem ser armazenados e utilizados como prova em um Tribunal de Justiça contra tais usuários.
		
		<br>

		</div>
	"

	# Limitation of Liability
	echo "

		<hr> **Limitação de Responsabilidade** 

		<div style=\"text-align: justify; line-height: 1.5; \"> 
		
		<p> Em nenhuma circunstância os Proprietários, seus fornecedores ou licenciadores serão responsáveis perante qualquer usuário ou terceiro pelo uso indevido ou pela confiança no Serviço. </p> 
		
		<hr> **Alterações aos Termos de Serviço e Rescisão** 
		
		<p> Podemos modificar ou encerrar o Serviço, bem como estes Termos de Serviço e quaisquer políticas associadas, por qualquer motivo e sem aviso prévio, incluindo o direito de encerramento com ou sem aviso, sem qualquer responsabilidade para com você, qualquer usuário ou terceiros. Revise estes Termos de Serviço periodicamente para estar ciente de quaisquer alterações. </p> 
		
		<p> Reservamo-nos o direito de encerrar seu uso do Serviço, por qualquer motivo e sem aviso prévio. Com tal rescisão, todos os direitos concedidos a você pelo Proprietário deste Hotspot serão revogados. </p>

		</div>
	"

	# Indemnity
	echo "
		<hr> **Indenização** 

		<div style=\"text-align: justify; line-height: 1.5; \"> 
		
		<p> **Você concorda** em isentar e indenizar os Proprietários deste Hotspot, seus fornecedores e licenciadores 
		de qualquer reclamação de terceiros decorrente ou de alguma forma relacionada ao seu uso do Serviço, incluindo qualquer 
		responsabilidade ou despesa resultante de todas as reclamações, perdas, danos (reais e consequenciais), processos, julgamentos, custos de litígio e honorários advocatícios, 
		de qualquer tipo e natureza. </p>

		</div>
		<hr>
		<form>
			<input type=\"button\" VALUE=\"Continue\" onClick=\"history.go(-1);return true;\">
		</form>
	"
	footer
}

#### end of functions ####


#################################################
#						#
#  Start - Main entry point for this Theme	#
#						#
#  Parameters set here overide those		#
#  set in libopennds.sh			#
#						#
#################################################

# Quotas and Data Rates
#########################################
# Set length of session in minutes (eg 24 hours is 1440 minutes - if set to 0 then defaults to global sessiontimeout value):
# eg for 100 mins:
# session_length="100"
#
# eg for 20 hours:
# session_length=$((20*60))
#
# eg for 20 hours and 30 minutes:
# session_length=$((20*60+30))
session_length="0"

# Set Rate and Quota values for the client
# The session length, rate and quota values could be determined by this script, on a per client basis.
# rates are in kb/s, quotas are in kB. - if set to 0 then defaults to global value).
upload_rate="0"
download_rate="0"
upload_quota="0"
download_quota="0"

quotas="$session_length $upload_rate $download_rate $upload_quota $download_quota"

# Define the list of Parameters we expect to be sent sent from openNDS ($ndsparamlist):
# Note you can add custom parameters to the config file and to read them you must also add them here.
# Custom parameters are "Portal" information and are the same for all clients eg "admin_email" and "location" 
ndscustomparams="input logo_message banner1_message banner2_message banner3_message"
ndscustomimages="logo_png banner1_jpg banner2_jpg banner3_jpg"
ndscustomfiles="advert1_htm"

ndsparamlist="$ndsparamlist $ndscustomparams $ndscustomimages $ndscustomfiles"

# The list of FAS Variables used in the Login Dialogue generated by this script is $fasvarlist and defined in libopennds.sh
#
# Additional FAS defined variables (defined in this theme) should be added to $fasvarlist here.
additionalthemevars=""

fasvarlist="$fasvarlist $additionalthemevars"

# You can choose to define a custom string. This will be b64 encoded and sent to openNDS.
# There it will be made available to be displayed in the output of ndsctl json as well as being sent
#	to the BinAuth post authentication processing script if enabled.
# Set the variable $binauth_custom to the desired value.
# Values set here can be overridden by the themespec file

#binauth_custom="This is sample text sent from \"$title\" to \"BinAuth\" for post authentication processing."

# Encode and activate the custom string
#encode_custom

# Set the user info string for logs (this can contain any useful information)
userinfo="$title"

# Customise the Logfile location. Note: the default uses the tmpfs "temporary" directory to prevent flash wear.
# Override the defaults to a custom location eg a mounted USB stick.
#mountpoint="/mylogdrivemountpoint"
#logdir="$mountpoint/ndslog/"
#logname="ndslog.log"



