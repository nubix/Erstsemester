require 'socket'
FGRAUM_IP='134.169.35.234'
FGRAUM_PORT=1337

msg=":blaaaah"
fgsocket = TCPSocket.open(FGRAUM_IP, FGRAUM_PORT)
fgsocket.puts msg
fgsocket.close
