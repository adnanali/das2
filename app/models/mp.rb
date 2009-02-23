require 'hpricot'
class Mp
  class << self
    def get_mp_from_site(postal_code)
      # clean up the postal code
      postal_code = clean_postal_code(postal_code)

      return false if postal_code == false

      url = "http://www2.parl.gc.ca" +
        "/Parlinfo/Compilations/HouseOfCommons/MemberByPostalCode.aspx" +
        "?Menu=HOC&PostalCode=" + postal_code

      doc = Hpricot(get_page(url))

      # name is in "last name, first name" format
      name = doc.search("#ctl00_cphContent_repMP_ctl00_lnkPerson").inner_html.strip
      (last_name, first_name) = name.split(", ")
      name = "#{first_name} #{last_name}".strip

      # extract parliamentary address
      paddress = "#{doc.search("#ctl00_cphContent_repMP_ctl00_grdParliamentaryAddress_ctl02_Label5").inner_html}\n" +
        "#{doc.search("#ctl00_cphContent_repMP_ctl00_grdParliamentaryAddress_ctl02_Label7").inner_html}\n" +
        "#{doc.search("#ctl00_cphContent_repMP_ctl00_grdParliamentaryAddress_ctl02_Label8").inner_html}\n"

      # extract local address
      laddress = "#{doc.search("#ctl00_cphContent_repMP_ctl00_grdConstituencyAddress_ctl02_Label3").inner_html}\n" +
        "#{doc.search("#ctl00_cphContent_repMP_ctl00_grdConstituencyAddress_ctl02_Label12").inner_html}, " +
        "#{doc.search("#ctl00_cphContent_repMP_ctl00_grdConstituencyAddress_ctl02_Label4").inner_html}\n" +
        "#{doc.search("#ctl00_cphContent_repMP_ctl00_grdConstituencyAddress_ctl02_Label13").inner_html}\n"

      city = doc.search("#ctl00_cphContent_repMP_ctl00_grdConstituencyAddress_ctl02_Label12").inner_html.strip
      province = doc.search("#ctl00_cphContent_repMP_ctl00_grdConstituencyAddress_ctl02_Label4").inner_html.strip

      mp_info = {
        'riding' => doc.search("#ctl00_cphContent_repMP_ctl00_lblYellowBar").inner_html.strip,
        'name' => name,
        'city' => city,
        'province' => province,
        'email' => doc.search("#ctl00_cphContent_repMP_ctl00_grdParliamentaryAddress_ctl02_HyperLink1").inner_html.strip,
        'party' => doc.search("#ctl00_cphContent_repMP_ctl00_lnkParty").inner_html.strip,
        'parliamentary_address' => {
          'address' => paddress.strip,
          'telephone' => doc.search("#ctl00_cphContent_repMP_ctl00_grdParliamentaryAddress_ctl02_repParliamentaryTelephones_ctl00_lblTelephonenumber").inner_html.strip,
          'fax' => doc.search("#ctl00_cphContent_repMP_ctl00_grdParliamentaryAddress_ctl02_repParliamentaryTelephones_ctl01_lblTelephonenumber").inner_html.strip,
          'email' => doc.search("#ctl00_cphContent_repMP_ctl00_grdParliamentaryAddress_ctl02_HyperLink1").inner_html.strip,
        },
        'local_address' => {
          'address' => laddress.strip,
          'telephone' => doc.search("#ctl00_cphContent_repMP_ctl00_grdConstituencyAddress_ctl02_repConstituencyTelephones_ctl00_lblTelephonenumber").inner_html.strip,
          'fax' => doc.search("#ctl00_cphContent_repMP_ctl00_grdConstituencyAddress_ctl02_repConstituencyTelephones_ctl01_lblTelephonenumber").inner_html.strip,
          'email' => doc.search("#ctl00_cphContent_repMP_ctl00_grdConstituencyAddress_ctl02_HyperLink1").inner_html.strip,
        }
      }

      mp_info
    end

    def clean_postal_code(postal_code)
      return false unless postal_code
      postal_code = postal_code.gsub(/[^A-Za-z0-9]/, '').upcase
      return false if postal_code.length != 6
      postal_code
    end

    def get_page(url)
      resp = ""
      p = URI.parse(url)
      http = Net::HTTP.new(p.host)
      http.start do |http|
        req = Net::HTTP::Get.new(p.path + "?" + p.query,
          {"User-Agent" => "spider"})
        response = http.request(req)
        resp = response.body
      end
      resp
    end
  end
end
