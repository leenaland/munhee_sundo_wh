package servlet.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import servlet.service.ServletService;

@Controller
public class ServletController {

	@Resource(name = "ServletService")
	private ServletService servletService;

	@RequestMapping(value = "/main.do")
	public String mainTest(Model model) {

		// 시도 리스트 출력하기
		List<Map<String, Object>> sdList = servletService.sdList();
		model.addAttribute("sdList", sdList);
		
		// 시도 차트에 넣어줄 데이터 가져오기
		List<Map<String, Object>> sdChartList = servletService.sdChartList();
		System.out.println(sdChartList);
		model.addAttribute("sdChartList", sdChartList);
		
		// 시군구 차트에 넣어줄 데이터 가져오기
		List<Map<String, Object>> sggChartList = servletService.sggChartList();
		System.out.println(sggChartList);
		model.addAttribute("sggChartList", sggChartList);
		
		return "main/main";
	}

	// 시군구
	// ajax 쓰려면 responsebody 넣어줘야 함.restcontroller 있으면 안써도 되고..
	@PostMapping(value = "/selectedSD.do")
	public @ResponseBody List<Map<String, Object>> testPage(@RequestParam("sdparam") String sdparam) {
		
		// sdparam 오는 것 확인
		System.out.println(sdparam);
		System.out.println("안녕안녕");

		// sgglist 출력
		List<Map<String, Object>> sggList = servletService.sggList(sdparam);
		System.out.println(sggList);

		return sggList;
	}

	@PostMapping("/read-file.do")
	public @ResponseBody String readfile(@RequestParam("upFile") MultipartFile upFile) throws IOException {
		System.out.println(upFile.getName());
		System.out.println(upFile.getContentType());
		System.out.println(upFile.getSize());
		
		List<Map<String, Object>> list = new ArrayList<>();
		
		InputStreamReader isr = new InputStreamReader(upFile.getInputStream());
		BufferedReader br = new BufferedReader(isr);

		String line = null;
		while ((line = br.readLine()) != null) {
			Map<String, Object> m = new HashMap<>();
			String[] lineArr = line.split("\\|");
			m.put("year_month", lineArr[0]); //사용_년월 date
			m.put("site_lo", lineArr[1]); //대지_위치 addr
			m.put("road_site_lo", lineArr[2]); //도로명_대지_위치 newAddr
			m.put("sgg_cd", lineArr[3]); //시군구_코드 sigungu
			m.put("bjdcode", lineArr[4]); //법정동_코드 bubjungdong
			m.put("site_div_cd", lineArr[5]); //대지_구분_코드 addrCode
			m.put("bun", lineArr[6]); //번 bun
			m.put("ji", lineArr[7]); //지 si
			m.put("new_addr_no", lineArr[8]); //새주소_일련번호 newAddrCode
			m.put("new_addr_road_cd", lineArr[9]); //새주소_도로_코드 newAddr
			m.put("new_addr_under_cd", lineArr[10]);//새주소_지상지하_코드newAddrUnder
			m.put("new_addr_main_no", lineArr[11]); //새주소_본_번 newAddrBun
			m.put("new_addr_sub_no", lineArr[12]); //새주소_부_번 newAddrBun2
			m.put("usage", lineArr[13]); //사용_량(KWh) usekwh
			
			list.add(m);
		}
		
		// 서비스로 list 보내기
		servletService.upfile(list);
		
		System.out.println("종료 : "+list);
		br.close();
		isr.close();
		
		return "success"; // @ResponseBody 는 해당 응답이 http 에 나타남. @Resposebody 없애고 redirect 넣음. @Resposebody는 ajax 용
	}
	
	// 범례 ajax 의 비동기 통신? 그냥 controller 까지만 써주는 것
	@PostMapping("/legend.do")
	public @ResponseBody Map<String, Object> legend(@RequestParam("legend") String legend){
		Map<String, Object> response = new HashMap<>();
		return response;
	}

}
