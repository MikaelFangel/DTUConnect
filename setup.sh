#!/bin/bash

# Check if nmcli is installed before running the script
if ! command -v nmcli &> /dev/null; then
    echo "nmcli is not installed. Exiting script..."
    exit 0
fi

# Skips a setup step if true
skipstep=1

# Check if creds have been taken already
credsload=1

# Checks if the connection profile already exists
function check_profile_exist() {
    if [[ $(echo $1 | awk 'NF{ print $NF }') == 0 ]]; then
        read -p "$2 Connection profile already exists.
Do you wish to delete and continue? [y/N] " answer

        if [[ $answer == "y" || $answer == "Y" ]]; then
            nmcli connection delete id $2
            skipstep=1
        else
            skipstep=0
        fi
    fi
}

function get_creds() {
    # Get user credentials
    if [[ credsload -ne 0 ]]; then
        read -r -p "Username: " username
        read -r -p "Password: " -s password
        echo
        credsload=0
    fi
}

function create_secure() {
    echo "Creating connection profile for DTUsecure..."
    
    get_creds

    # Gets the name of the wireless interface using nmcli
    interface=$(nmcli dev status | grep -E "(^| )wifi( |$)" | awk '{print $1}')

    Creates connection profile
    nmcli connection add \
        type wifi con-name "DTUsecure" ifname $interface ssid "DTUsecure" -- \
        wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
        802-1x.identity $username 802-1x.password $password \
        802-1x.anonymous-identity "anonymous@dtu.dk"
}

function create_cert() {
echo "-----BEGIN CERTIFICATE-----
MIIFszCCA5ugAwIBAgIQGPyTPfToyJJPRg/BlCoZMjANBgkqhkiG9w0BAQsFADBO
MQswCQYDVQQGEwJESzEmMCQGA1UEChMdRGFubWFya3MgVGVrbmlza2UgVW5pdmVy
c2l0ZXQxFzAVBgNVBAMTDkRUVSBST09UIENBIDAxMB4XDTE1MTIwMjExMDQ0OFoX
DTQwMTIwMjExMTQ0OFowTjELMAkGA1UEBhMCREsxJjAkBgNVBAoTHURhbm1hcmtz
IFRla25pc2tlIFVuaXZlcnNpdGV0MRcwFQYDVQQDEw5EVFUgUk9PVCBDQSAwMTCC
AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANDKEUG7jDTxJW9L2FeE4nV7
5ejarzkrkRz8wpmK+jpA/IqowG1yi/TDk77yastCBLnt0J7GhbUestDx27QcgpmS
kVNM3F6JAxCFSmswmtOTHRwC1Vp9q7RunVi3fH5NZB8n5d/KnRmS6qpq9xoNxR+1
B+J1dd5EopqfYynwCimyYdXVmuJSeRC/mLm7N5/8PPiggrQSboHc1hA1S63s4oow
ME7mFogdS5tn4k+TBgT75q48zGEzJ2p8HeoMH5h/t+t7UJWuM7valf0dyjKvtIYu
Fe9hdPIX6mtFmhBJBZR3a82UG8Vc1WOKBVZtvAA+YjXgSFyPOIfTtTLSideS0dbV
Hs5fSIIkLsQo+qZ+BOBIwgVj8KH4Tzds/c7YKLeXLQAzZn3hJ8ShZb77ZTn5YAMw
sUmJPRUWyMJZxuBhLNty4GfX58D628ELgZdk8gCxr8okt0G8gMMWiFGNbXPM+p1e
z2qla8toHNvz4FKjbV1Wo303Qk0VPxT5iIF7l4voAIFwRmdlrYy1aU9auvE+E3km
84kzkY68V8Rxt/Ig+1dUmngSFyS81VWndpbPzKZtwMHlaFrtxPVlAQiI7y4vvUtU
GYUdscHe736/itpipfyOk8Y+bvtdKei2AFynUu7nfe1ylz21jZ4LFZ4ICxXldCHJ
eW4EuAll5JBRdOJ09G0vAgMBAAGjgYwwgYkwCwYDVR0PBAQDAgGGMA8GA1UdEwEB
/wQFMAMBAf8wHQYDVR0OBBYEFEGHGrJtr9H49tSOY1yMgdi7Pk7FMBIGCSsGAQQB
gjcVAQQFAgMBAAEwEQYDVR0gBAowCDAGBgRVHSAAMCMGCSsGAQQBgjcVAgQWBBTB
yFfc2YDjEQRdRBoMdYAnYLCu1DANBgkqhkiG9w0BAQsFAAOCAgEAb1L5CcG3w+rd
WHsjxtu19tsLJjwjhfYezADbw8HXKnOcaP9fLrPDRP3YHIJK/LSOYHn2z2Ltb6wl
rDB+0l1WhTyUIVluNXKmbeeQ7KhmvAhZXnCbZ2ibodaRndSHRc62c4jIoUtyHgzb
2PT4nGXZ3UAfSJUhpIDXf9d/B8HVD4PBbqCHeB+16Dd4DusxC+n8jW9yCLWqFfrp
C/7D3nueSOzBAqc0hx5f9zWffI99AN9hNSUn9u9TsFOhyvbYtVAelO+cQeN5uXjc
vMJu44j6tbaJJCmZir9cvst//fRQKe/FW7E4xpQ/PYI4/OhY++xY3VtDFKk8YWwj
kPVX14ZThvFgLTUIpfc6XCDGJD1QYbdXoONKsdzVngv5KSPXxDGR7E85q/HKExvm
8bJteqBMEr9brBjVpT4SJruSoEwT1DU7mITJU0s84SMPgGX0W0Z04EgavJgfwb8V
3dVcdOSfRGI9O3P9u7TFHDLXFBkOcbJEq9+q7fZ2NWQ+ahV/0Vp0XOLxsueRk1J8
WaW2hKLjhHMEAvIq4fvID+CwOaKwa91Q9e4QjffG385IAA2St2iYV1qfC7Gw9rnG
G0If+819pZ0HnHtKUlzOAz4Yh7gbPIQFNObDKQTT6rZrL2fJLoZ5kk0/g4BKfGFd
3mihppQSBG7qQF84ErbTO80Pn2Il7L8=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIGdzCCBF+gAwIBAgIKYRCS3AABAAAACTANBgkqhkiG9w0BAQsFADBOMQswCQYD
VQQGEwJESzEmMCQGA1UEChMdRGFubWFya3MgVGVrbmlza2UgVW5pdmVyc2l0ZXQx
FzAVBgNVBAMTDkRUVSBST09UIENBIDAxMB4XDTE1MTIwMjExMTkxMVoXDTI3MTIw
MjExMjkxMVowcDESMBAGCgmSJomT8ixkARkWAmRrMRMwEQYKCZImiZPyLGQBGRYD
ZHR1MRMwEQYKCZImiZPyLGQBGRYDd2luMTAwLgYDVQQDEydBZmRlbGluZ2VuIGZv
ciBJVCBTZXJ2aWNlIElzc3VpbmcgQ0EgMDIwggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQCjfR055ycQHow0JsvgrywYMFnrf0ETzBQ3qhyW4R87m/KOQgBv
Mn/q3lFGMpFabSxv2auTBe4ZKwOyVbIW1dLNtwBDUZ0Ix1LUUdOlwi83YqmGBObe
rT7hUmNFvaykDjnizszjLpHIxydsdK368u4oclCTPS2Lb5eMMhanwRNVpDtyeoPB
TA3hw/yq9yaDqv49D7diqCPxAC6rwTkjTirs4On8y6WSqiRSDP656XMo6NhTk8f1
dy+8zCvHih7tgzvrAReReR3bbPVx8v3ZIRcRSoKXLXP3wU3bPjHBuOJgSZoI7U+b
tFq9XIwxWG77PDe7OyGx11297d995CL8CrU7AgMBAAGjggIzMIICLzASBgkrBgEE
AYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBTMZ8ENgxEXj672axmHA73ZdGc6
vTAdBgNVHQ4EFgQUBhPbV1NxrI24r7VdZ487d3Ld3D8wgdoGA1UdIASB0jCBzzCB
xAYLKwYBBAHYXIN9AwEwgbQwgYYGCCsGAQUFBwICMHoeeABEAGEAbgBtAGEAcgBr
AHMAIABUAGUAawBuAGkAcwBrAGUAIABVAG4AaQB2AGUAcgBzAGkAdABlAHQAIABD
AGUAcgB0AGkAZgBpAGMAYQB0AGUAIABQAHIAYQBjAHQAaQBjAGUAIABTAHQAYQB0
AGUAbQBlAG4AdDApBggrBgEFBQcCARYdaHR0cDovL3BraS53aW4uZHR1LmRrL3Bv
bGljeS8wBgYEVR0gADAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8E
BAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRBhxqyba/R+PbUjmNc
jIHYuz5OxTBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vcGtpLndpbi5kdHUuZGsv
RFRVJTIwUk9PVCUyMENBJTIwMDEoMSkuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggr
BgEFBQcwAoY+aHR0cDovL3BraS53aW4uZHR1LmRrL1dJTi1ST09UQ0EwMV9EVFUl
MjBST09UJTIwQ0ElMjAwMSgxKS5jcnQwDQYJKoZIhvcNAQELBQADggIBAK62o90Z
QCDB4hsFRi9IoyrgL8fTJS3PTTXSsdnyRoXAQJzzAsWvvg4iTIMjJmpnYffB07Ax
mAmfJ7mueWVqZ7S0TwZjqgIZJmzzYV44eLn6CUq5Ua5UwaLCv+gsVnz/lR43BWCT
/heKHq6W64ST2whi4f/uhlaQj5zgsMXPtBgLDRsEvXUlrVHilaU7/4PtheeRGdbY
hAXnN6qCJlOeZIrgVtvBqG8hoe4f5pqXsJ4hPRKYxBcA1RI1tb6Z20L3f5+ppqNM
MbOqBTbtRL1IZl0ktLouiOo9/s9rTnDxaFotWp370mGbTqaOuNIxHfhuJC/koaTf
Z3MyMBduQKRh8UzTrM+vkkYww8kG2+ZvAvUl3v6Co27kl37MGleJtxjNsejLx9A5
XKSU29pMG/dHtPWRjlBOZXKuGzcs6TzY1i/HPxmGXn2xmXe4Zxt3akJTZJStZ5xu
4afLprlCYR9Wc7w5FUG6WkrvWBZD9r6UYuQQSknK5KqdL2rymI/4Dp0IYE1ykZXX
P6DFULwVXIypQVwRY2L+JxBJ8EeUEc8LciJjhKFHf2zYwh2B27zDTIcEMXZPvZ42
JaWb94x0JkaiKwPGwTO/Qf//yLhpkhTTat1HmfpsQsd8GQosAdG7DmGT2b84Ps5T
mj11TwBgoKu/qe7tW3wijRQABbjO7EUCtRYq
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
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
wQA2RQg=
-----END CERTIFICATE-----
" > $HOME/.config/ca_edu.pem
}

function create_eduroam() {
    echo "Creating connection profile for eduroam..."

    get_creds

    echo "Creating certificate at $HOME/.config/ca_edu.pem"
    create_cert

    echo "Adding connection profile for eduroam..."
    nmcli connection add \
        type wifi con-name "eduroam" ifname $interface ssid "eduroam" connection.permissions "user:$USER" -- \
        wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 \
        wifi-sec.proto rsn wifi-sec.pairwise ccmp wifi-sec.group "ccmp,tkip" \
        802-1x.identity $username 802-1x.password $password 802-1x.ca-cert $HOME/.config/ca_edu.pem \
        802-1x.anonymous-identity "anonymous@dtu.dk" \
        802-1x.altsubject-matches "DNS:ait-pisepsn03.win.dtu.dk,DNS:ait-pisepsn04.win.dtu.dk"
}

function main() {
    nwid="DTUsecure"
    state=$(nmcli -f GENERAL.STATE con show $nwid; echo $?)
    check_profile_exist "$state" "$nwid"

    if [[ $skipstep -ne 0 ]]; then
        create_secure
    fi

    nwid="eduroam"
    read -p "Do you want to setup $nwid also? [Y/n]" continue
    if [[ $continue != "n" && $continue != "N" ]]; then
        state=$(nmcli -f GENERAL.STATE con show $nwid; echo $?)
        check_profile_exist "$state" "$nwid"

        if [[ $skipstep -ne 0 ]]; then
            create_eduroam
        fi
    fi

    echo "Exiting script..."
}

main
