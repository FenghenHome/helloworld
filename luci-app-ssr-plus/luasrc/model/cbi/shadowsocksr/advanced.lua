local uci = luci.model.uci.cursor()
local server_table = {}

uci:foreach("shadowsocksr", "servers", function(s)
	if s.alias then
		server_table[s[".name"]] = "[%s]:%s" % {string.upper(s.v2ray_protocol or s.type), s.alias}
	elseif s.server and s.server_port then
		server_table[s[".name"]] = "[%s]:%s:%s" % {string.upper(s.v2ray_protocol or s.type), s.server, s.server_port}
	end
end)

local key_table = {}
for key, _ in pairs(server_table) do
	table.insert(key_table, key)
end

table.sort(key_table)

m = Map("shadowsocksr")
-- [[ global ]]--
s = m:section(TypedSection, "global", translate("Server failsafe auto swith and custom update settings"))
s.anonymous = true

-- o = s:option(Flag, "monitor_enable", translate("Enable Process Deamon"))
-- o.rmempty = false
-- o.default = "1"

o = s:option(Flag, "enable_switch", translate("Enable Auto Switch"))
o.rmempty = false
o.default = "1"

o = s:option(Value, "switch_time", translate("Switch check cycly(second)"))
o.datatype = "uinteger"
o:depends("enable_switch", "1")
o.default = 667

o = s:option(Value, "switch_timeout", translate("Check timout(second)"))
o.datatype = "uinteger"
o:depends("enable_switch", "1")
o.default = 5

o = s:option(Value, "switch_try_count", translate("Check Try Count"))
o.datatype = "uinteger"
o:depends("enable_switch", "1")
o.default = 3

o = s:option(Value, "gfwlist_url", translate("gfwlist Update url"))
o:value("https://fastly.jsdelivr.net/gh/FenghenHome/filters@gh-pages/dnsmasq.gfw-domains.conf", translate("FenghenHome gfw list"))
o.default = "https://fastly.jsdelivr.net/gh/FenghenHome/filters@gh-pages/dnsmasq.gfw-domains.conf"

o = s:option(Value, "chnroute_url", translate("Chnroute Update url"))
o:value("https://fastly.jsdelivr.net/gh/17mon/china_ip_list/china_ip_list.txt", translate("Clang.CN"))
o.default = "https://fastly.jsdelivr.net/gh/17mon/china_ip_list/china_ip_list.txt"

o = s:option(Flag, "netflix_enable", translate("Enable Netflix Mode"))
o.rmempty = false

o = s:option(Value, "nfip_url", translate("nfip_url"))
o:value("https://fastly.jsdelivr.net/gh/QiuSimons/Netflix_IP/NF_only.txt", translate("Netflix IP Only"))
o:value("https://fastly.jsdelivr.net/gh/QiuSimons/Netflix_IP/getflix.txt", translate("Netflix and AWS"))
o.default = "https://fastly.jsdelivr.net/gh/QiuSimons/Netflix_IP/NF_only.txt"
o.description = translate("Customize Netflix IP Url")
o:depends("netflix_enable", "1")

o = s:option(ListValue, "shunt_dns_mode", translate("DNS Query Mode For Shunt Mode"))
o:value("1", translate("Use DNS2SOCKS query and cache"))
o:value("2", translate("Use MOSDNS query"))
o:depends("netflix_enable", "1")
o.default = 1

o = s:option(Value, "shunt_dnsserver", translate("Anti-pollution DNS Server For Shunt Mode"))
o:value("8.8.4.4:53", translate("Google Public DNS (8.8.4.4)"))
o:value("8.8.8.8:53", translate("Google Public DNS (8.8.8.8)"))
o:value("208.67.222.222:53", translate("OpenDNS (208.67.222.222)"))
o:value("208.67.220.220:53", translate("OpenDNS (208.67.220.220)"))
o:value("209.244.0.3:53", translate("Level 3 Public DNS (209.244.0.3)"))
o:value("209.244.0.4:53", translate("Level 3 Public DNS (209.244.0.4)"))
o:value("4.2.2.1:53", translate("Level 3 Public DNS (4.2.2.1)"))
o:value("4.2.2.2:53", translate("Level 3 Public DNS (4.2.2.2)"))
o:value("4.2.2.3:53", translate("Level 3 Public DNS (4.2.2.3)"))
o:value("4.2.2.4:53", translate("Level 3 Public DNS (4.2.2.4)"))
o:value("1.1.1.1:53", translate("Cloudflare DNS (1.1.1.1)"))
o:depends("shunt_dns_mode", "1")
o.description = translate("Custom DNS Server format as IP:PORT (default: 8.8.4.4:53)")
o.datatype = "ip4addrport"

o = s:option(ListValue, "shunt_mosdns_dnsserver", translate("Anti-pollution DNS Server"))
o:value("tcp://8.8.4.4:53,tcp://8.8.8.8:53", translate("Google Public DNS"))
o:value("tcp://208.67.222.222:53,tcp://208.67.220.220:53", translate("OpenDNS"))
o:value("tcp://209.244.0.3:53,tcp://209.244.0.4:53", translate("Level 3 Public DNS-1 (209.244.0.3-4)"))
o:value("tcp://4.2.2.1:53,tcp://4.2.2.2:53", translate("Level 3 Public DNS-2 (4.2.2.1-2)"))
o:value("tcp://4.2.2.3:53,tcp://4.2.2.4:53", translate("Level 3 Public DNS-3 (4.2.2.3-4)"))
o:value("tcp://1.1.1.1:53,tcp://1.0.0.1:53", translate("Cloudflare DNS"))
o:depends("shunt_dns_mode", "2")
o.description = translate("Custom DNS Server for mosdns")

o = s:option(Flag, "shunt_mosdns_ipv6", translate("Disable IPv6 In MOSDNS Query Mode (Shunt Mode)"))
o:depends("shunt_dns_mode", "2")
o.rmempty = false
o.default = "0"

o = s:option(Flag, "adblock", translate("Enable adblock"))
o.rmempty = false

o = s:option(Value, "adblock_url", translate("adblock_url"))
o:value("https://fastly.jsdelivr.net/gh/FenghenHome/filters@gh-pages/dnsmasq.adblock-domains.conf", translate("FenghenHome adblock list"))
o.default = "https://fastly.jsdelivr.net/gh/FenghenHome/filters@gh-pages/dnsmasq.adblock-domains.conf"
o:depends("adblock", "1")
o.description = translate("Support AdGuardHome and DNSMASQ format list")

o = s:option(Button, "reset", translate("Reset to defaults"))
o.rawhtml = true
o.template = "shadowsocksr/reset"

-- [[ SOCKS5 Proxy ]]--
s = m:section(TypedSection, "socks5_proxy", translate("Global SOCKS5 Proxy Server"))
s.anonymous = true

o = s:option(ListValue, "server", translate("Server"))
o:value("nil", translate("Disable"))
o:value("same", translate("Same as Global Server"))
for _, key in pairs(key_table) do
	o:value(key, server_table[key])
end
o.default = "nil"
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1080
o.rmempty = false

return m
