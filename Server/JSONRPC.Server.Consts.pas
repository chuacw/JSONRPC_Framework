unit JSONRPC.Server.Consts;

interface

resourcestring
  sPortInUse = '- Error: Port %d already in use';
  sPortSSet = '- Port set to %s';
  sPortISet = '- Port set to %d';
  sServerAlreadyRunning = '- The server is already running';
  sServerStarted = '- The server has started on port %d';
  sStartingServer = '- Starting HTTP Server on port %d';
  sStoppingServer = '- Stopping server';
  sServerStopped = '- server stopped';
  sServerNotRunning = '- The server is not running';
  sInvalidCommand = '- Error: Invalid Command';
  sActive = '- Active: ';
  sPort = '- Port: ';
  sSessionID = '- Session ID CookieName: ';
  sCommands = 'Enter a Command: ' + slineBreak +
    '   - "start" to start the server'+ slineBreak +
    '   - "stop" to stop the server'+ slineBreak +
    '   - "set port" to change the default port'+ slineBreak +
    '   - "status" for Server status'+ slineBreak +
    '   - "help" to show commands'+ slineBreak +
    '   - "exit" to close the application';

const
  cArrow = '->';
  cCommandStart = 'start';
  cCommandStop = 'stop';
  cCommandStatus = 'status';
  cCommandHelp = 'help';
  cCommandSetPort = 'set port';
  cCommandExit = 'exit';
  cCommandQUit = 'quit';

implementation

end.



































// chuacw, Jun 2023

