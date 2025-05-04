
# スナップ 上
```
sh -c "wmctrl -r :ACTIVE: -e 0,0,$((`xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f 2` * 50 / 100)),$((`xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f 1` * 100 / 100)),$((`xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f 2` * 50 / 100 - 100))"
```

# スナップ 左
```
sh -c "wmctrl -r :ACTIVE: -e 0,0,0,$((`xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f 1` * 50 / 100)),$((`xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f 2` * 100 / 100 - 100))"
```

# スナップ 右
```
sh -c "wmctrl -r :ACTIVE: -e 0,$((`xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f 1` * 50 / 100)),0,$((`xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f 1` * 50 / 100)),$((`xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f 2` * 100 / 100 - 100))"
```

# スナップ 上
```
sh -c "wmctrl -r :ACTIVE: -e 0,0,0,$((`xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f 1` * 100 / 100)),$((`xdpyinfo | awk '/dimensions/{print $2}' | cut -d 'x' -f 2` * 50 / 100 - 100))"
```

# 最大化
```
sh -c "wmctrl -r :ACTIVE: -e 0,0,0,$((`xdpyinfo | awk '/dimensions/{print \$2}' | cut -d 'x' -f 1`)),$
((`xdpyinfo | awk '/dimensions/{print \$2}' | cut -d 'x' -f 2` - 100))"
```

