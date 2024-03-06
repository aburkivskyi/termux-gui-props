# termux-gui-props
A graphical utility for changing [Termux](https://github.com/termux/termux-app) properties



### Features

[x] changing [Termux](https://github.com/termux/termux-app) properties  
[ ] backup/restore properties  
[ ] reset properties to default  


### Installation

#### Github

Download a file from the [GitHub releases](https://github.com/aburkivskyi/termux-gui-props/releases).  
Install [termux-gui-bash](https://github.com/tareksander/termux-gui-bash) with `pkg install termux-gui-bash`.  
Install the [Termux:GUI app](https://github.com/termux/termux-gui).


### Dependencies

- `bash` (should be installed by default in Termux)
- [termux-gui-bash](https://github.com/tareksander/termux-gui-bash) package
- [jq](https://github.com/stedolan/jq) package (only need to be installed manually when building `termux-gui-bash` from source)
- The [Termux:GUI app](https://github.com/termux/termux-gui)


### License

The license is the [Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/2.0/).  
TL;DR: You can use this library in your own projects, regardless of the license you choose for it. Modifications to this
library have to be published under the MPL 2.0 (or a GNU license in some cases) though.