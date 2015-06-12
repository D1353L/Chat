require 'rubygems'
require './lib/ClientModel'
require './lib/ClientController'
require './lib/HistoryWindow'
require './lib/ImageListCellRenderer'
require './lib/MouseAction'
require './lib/MsgWindow'
require './lib/Security'
require './lib/UserDataWindow'
require 'socket'
require 'json'
require 'date'
require './lib/ClientGUI'

class Main
def initialize
$msgWindows = Array.new #Array for message windows
$historyWindows = Array.new #Array for history windows
$userDataWindows = Array.new #Array for userdata windows
$app = ClientGUI.new #Start application
end
end

Main.new

event_thread = nil
SwingUtilities.invokeAndWait { event_thread = java.lang.Thread.currentThread }
event_thread.join