require 'rubygems'
require 'ClientModel'
require 'ClientController'
require 'HistoryWindow'
require 'ImageListCellRenderer'
require 'MouseAction'
require 'MsgWindow'
require 'Security'
require 'UserDataWindow'
require 'socket'
require 'json'
require 'date'
require 'ClientGUI'

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