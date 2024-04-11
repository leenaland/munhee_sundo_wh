<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!-- jstl 선언문 -->
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html lang="ko">
<!-- 부트스트랩 css -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>브이월드 오픈API</title>
<script src="https://code.jquery.com/jquery-3.6.0.js"
	integrity="sha256-H+K7U5CnXl1h5ywQfKtSj8PCmoN9aaq30gDh27Xc0jk="
	crossorigin="anonymous"></script>
<script src="https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v6.15.1/build/ol.js"></script>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/ol@v6.15.1/ol.css">
<!-- 제이쿼리 -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<!-- 구글 차트 -->
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>

<title>2DMap</title>

<script type="text/javascript">

$( document ).ready(function() {
	
   let map = new ol.Map({ // OpenLayer의 맵 객체를 생성한다.
       target: 'map', // 맵 객체를 연결하기 위한 target으로 <div>의 id값을 지정해준다.
       layers: [ // 지도에서 사용 할 레이어의 목록을 정의하는 공간이다.
         new ol.layer.Tile({
           source: new ol.source.OSM({
             url: 'https://api.vworld.kr/req/wmts/1.0.0/A39B22E8-1EF6-346D-A2DF-7F4343E4E610/Base/{z}/{y}/{x}.png' // vworld의 지도를 가져온다.
           })
         })
       ],
       view: new ol.View({ // 지도가 보여 줄 중심좌표, 축소, 확대 등을 설정한다. 보통은 줌, 중심좌표를 설정하는 경우가 많다.
         center: ol.proj.fromLonLat([128.4, 35.7]),
         zoom: 7
       })
   });

   /* tl_sd 레이어 */
   var wms_tl_sd = new ol.layer.Tile({
      source : new ol.source.TileWMS({
         target: 'wms_tl_sd',
         url : 'http://wisejia.iptime.org:8080/geoserver/chorok/wms?service=WMS', // 1. 레이어 URL
         params : {
            'VERSION' : '1.1.0', // 2. 버전
            'LAYERS' : 'chorok:tl_sd', // 3. 작업공간:레이어 명
            'BBOX' : [1.3867446E7,3906626.5,1.4684055E7,4670269.5], 
            'SRS' : 'EPSG:3857', // SRID
            'FORMAT' : 'image/png' // 포맷
      //    'CQL_FILTER': "sd_cd = 11"
         },
         serverType : 'geoserver',
      })
   });
   
   $('select[name=sdselect]').on('change',function(){
	   
	var sdparam = $(this).val().split(',')[0];
  	 
	/* 시/도 geom값을 가져와서 확대 */
	var geom = $(this).val().split(',')[1]; // x 좌표
	alert("도시코드:"+sdparam+", 좌표:"+geom);
	
	var regex = /POINT\(([-+]?\d+\.\d+) ([-+]?\d+\.\d+)\)/;
    var matches = regex.exec(geom);
    var xCoordinate, yCoordinate;
    
    if (matches) {
        xCoordinate = parseFloat(matches[1]); // x 좌표
        yCoordinate = parseFloat(matches[2]); // y 좌표
    } else {
        alert("GEOM값 가져오기 실패!");
    }

    var sidoCenter = ol.proj.fromLonLat([xCoordinate, yCoordinate]);
    map.getView().setCenter(sidoCenter); // 중심좌표 기준으로 보기
    map.getView().setZoom(11.5); // 중심좌표 기준으로 줌 설정
  	 
  	 // PARAM 추가해줘야 AJAX 로 PARAM 보내줄 수 있음
	wms_tl_sd.getSource().updateParams({'CQL_FILTER' : "sd_cd = " + sdparam});
  	 
	map.addLayer(wms_tl_sd); // 맵 객체에 레이어를 추가함
    
    /* 시도 선택 후 시군구 불러오기 */
  	let sggOpt = `<option value="0">--시/군/구--</option>`; // 시군구 Option html String
  	let sggDd = document.querySelector("#sggselect"); // 시군구 드롭다운  
  	
  	 // 선택된 시도 코드를 서버로 전송
   	 $.ajax({
  		 type : 'post',
  		 url : '/selectedSD.do',
  		dataType : "json",
  		 data : {'sdparam' : sdparam}, // 키 : 값
  		success: function(data) {
  			console.log(data); // 배열로 출력됨. 이거 가져다 쓰면 됨!! (오류 해결)
  			sggDd.innerHTML = "";
  			for(let i = 0; i < data.length;i++) {
                sggOpt += "<option value='"+ data[i].sgg_cd+"'>"+ data[i].sgg_nm+"</option>";
             }
  			sggDd.innerHTML = sggOpt;
  		},
  		 error : function(error){
  			 alert("문제발생"+error);
  		 }
  	 }); 
   });
   
  	$('#sggselect').on('change',function(){
  		 let sggparam = $("#sggselect option:checked").val();
  		 console.log(sggparam);
  		
	// 새로운 wms_tl_sgg 레이어를 생성하여 할당
  	wms_tl_sgg = new ol.layer.Tile({
  		source : new ol.source.TileWMS({
			target: 'wms_tl_sgg',
			url : 'http://wisejia.iptime.org:8080/geoserver/chorok/wms?service=WMS', // 1. 레이어 URL
			params : {
				'VERSION' : '1.1.0', // 2. 버전
				'LAYERS' : 'chorok:tl_sgg', // 3. 작업공간:레이어 명
				'BBOX' : [1.386872E7,3906626.5,1.4428071E7,4670269.5], 
				'SRS' : 'EPSG:3857', // SRID
				'FORMAT' : 'image/png' // 포맷
			},
				serverType : 'geoserver',
		})
	});
		// 새로운 wms_tl_sgg 레이어에 필요한 필터 적용
		wms_tl_sgg.getSource().updateParams({'CQL_FILTER' : "sgg_cd = " + sggparam});
  	  	 
		// 맵에 새로운 wms_tl_sgg 레이어 추가
		map.addLayer(wms_tl_sgg); // 맵 객체에 레이어를 추가함
  		
	});
  	
  	/* 범례 적용 */
  	$("#legendbtn").click(function(){
  		
  		var legend = $("#legendselect").val();
  		let sggparam = $("#sggselect option:checked").val(); /* 아래에서 cql 필터로 걸러줄거 선언 */
  		map.removeLayer(wms_tl_sd);
        map.removeLayer(wms_tl_sgg);
        
        var style = (legend === "1") ? 'c4_bomrea_eq' : 'c4_bomrea_na'; /* geoserver에서 만든 스타일 이름으로 적기 */
        alert((legend === "1") ? "등간격 스타일을 적용합니다." : "네추럴 브레이크 스타일을 적용합니다.");
        
        $.ajax({
        	url: "/legend.do",
        	type: 'POST',
        	dataType: "json",
        	data: {"legend":legend},
        	success: function(result){
        		console.log(sggparam);
          		var c4bjdview = new ol.layer.Tile({
         		     source : new ol.source.TileWMS({
         		        target: 'c4bjdview',
         		        url : 'http://wisejia.iptime.org:8080/geoserver/chorok/wms?service=WMS', // 1. 레이어 URL
         		        params : {
         		           'VERSION' : '1.1.0', // 2. 버전
         		           
         		           'LAYERS' : '	chorok:c4bjdview', // 3. 작업공간:레이어 명
         		           'BBOX' : [1.3873946E7,3906626.5,1.4428045E7,4670269.5], 
         		           'SRS' : 'EPSG:3857', // SRID
         		           'FORMAT' : 'image/png', // 포맷
							'STYLES': style
         		        },
         		        serverType : 'geoserver',
         		     })
         		  });
          		// 새로운 c4bjdview 레이어에 필요한 필터 적용
        		c4bjdview.getSource().updateParams({'CQL_FILTER' : "sgg_cd = " + sggparam});
          		map.addLayer(c4bjdview);
        	},
        	error: function(){
        		alert("범례실패");
        	}
        });
  	});
  	
  	
});
 

// 파일 업로드
$(document).ready(function() {
    // 파일 업로드 폼 제출 이벤트 처리
    $('#uploadBtn').on('click', function() {
    	var formData =  new FormData();
    	// 파일 입력 요소에서 파일 가져오기
        var fileInput = document.getElementById('upFile').files[0];
    	var fileName = fileInput.name;
    	alert(fileName);
        
        // 파일 체크 함수
        var fileExtension = fileName.substring(fileName.lastIndexOf(".") + 1);
        if(fileExtension.toLowerCase() !== "txt"){
        	alert("txt 파일만 업로드 해주세요");
        	return false; // 파일 업로드를 중지
        }
        
    	 // 모달 창 표시
        $('#uploadModal').modal('show');
        
    	 // FormData에 파일 추가
        formData.append('upFile', fileInput);
        
        // 파일 업로드 ajax
        $.ajax({
            url: '/read-file.do',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            xhr : function(){ // 프로그레스 바 : XMLHttpReqest 재정의 가능
            	var xhr = $.ajaxSettings.xhr();
            	xhr.upload.onprogress = function(e){ // progress 이벤트 리스너 추가
            		var percent = e.loaded * 100 / e.total;
            		$('#progressBar').width(percent + "%").attr('aria-valuenow', percent);
            	};
            	return xhr;
            },
            success: function(response) {
            	
            	// 1초 후 모달 닫기
                setTimeout(function(){
                  $('#uploadModal').modal('hide');
                  if (response.trim() === "success") {
                    alert("파일업로드 성공");
                  } else{
                    alert("파일업로드 실패");
                  }
                }, 1000);
            	
            	// 파일 업로드 성공 또는 실패 시 파일 업로드 폼 리셋
                $('#upFileForm')[0].reset();

            },
            error: function(xhr, status, error) {
                $('#uploadModal').modal('hide');
                // 서버와 통신 실패 알림 표시
                alert("서버와 통신 실패");
                console.error(xhr.responseText);
             	// 파일 업로드 성공 또는 실패 시 파일 업로드 폼 리셋
                $('#upFileForm')[0].reset();
            }
        });
    });
});

</script>


<style type="text/css">
.map {
	height: 100vh;
	width: 80%;
	float: right; /* 지도 오른쪽으로 밀기 */
}

.title {
	width: 20%;
    background-color: lightgray; /* 네모 박스 배경색 */
    padding: 10px;
    border: 1px solid black; /* 네모 박스 테두리 */
    text-align: center;
    margin-bottom: 10px;
}

.nav {
	width: 5%;
	float: left; /* 지도 오른쪽으로 밀기 */
}

</style>
</head>

<body>
<!-- 부트스트랩 js -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
	
	<div id="map" class="map"></div>
	
	<div class="title"><h2>전기사용 GIS</h2></div>
	
	<!-- 파일업로드 폼 -->
	<div class="col-2">
	<form enctype="multipart/form-data" id="upFileForm">
 		<input class="form-control  mb-2" type="file" name="upFile" accept=".txt" id="upFile">
 		<button type="button" id="uploadBtn" class="btn btn-primary mb-2">파일 업로드</button>
	</form>
	</div>
	
	<!-- 모달 창 -->
	<div class="modal mb-2" id="uploadModal" tabindex="-1" aria-labelledby="uploadModalLabel" aria-hidden="true">
  		<div class="modal-dialog">
    		<div class="modal-content">
      			<div class="modal-header">
        		<h5 class="modal-title" id="uploadModalLabel">파일 업로드 중...</h5>
      			</div>
      			<div class="modal-body">
        			<!-- 프로그레스 바 -->
        			<div class="progress">
          				<div id="progressBar" class="progress-bar" role="progressbar" style="width: 0%;" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
        			</div>
      			</div>
    		</div>
		</div>
	</div>

	<!-- 시도 선택  -->
	<div class="col-2 mb-2">
		<select name="sdselect" class="form-select" aria-label="Default select example">
			<option selected>--시도--</option>
			<c:forEach items="${sdList }" var="sd">
				<option value="${sd.sd_cd }, ${sd.geom }">${sd.sd_nm }</option>
			</c:forEach>
		</select>
	</div>
		
	<!-- 시군구 선택  -->
	<div class="col-2 mb-2">
		<select id="sggselect" name="sggselect" class="form-select" aria-label="Default select example">
			<option selected>--시/군/구--</option>
		</select>
	</div>
		
	<!-- 범례 선택 -->
	<div class="col-2 mb-2">
		<select id="legendselect" class="form-select" aria-label="Default select example">
			<option selected>--범례--</option>
			<option value="1">등간격</option>
			<option value="2">네츄럴 브레이크</option>
		</select>
	</div>
		
	<!-- 선택 정보 입력 버튼 -->
	<div class="col-2 mb-2">
		<button type="button" class="btn btn-primary" id="legendbtn">정보 입력</button>
	</div>
	
	<!-- 정보 새로고침 버튼 -->
	<div class="col-2 mb-2">
		<button type="button" class="btn btn-primary">정보 새로고침</button>
	</div>
	
	<!-- 차트 도시 선택 박스  -->
	<div class="col-2 mb-2">
		<select id="ChartSelect" class="form-select" aria-label="Default select example">
			<option selected>--시도--</option>
			<option value="all">전체</option>
			<c:forEach items="${sdList }" var="sd">
				<option value="${sd.sd_cd }">${sd.sd_nm }</option>
			</c:forEach>
		</select>
	</div>
	
	<!-- 차트 선택 버튼 -->
	<button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#chart"><!-- 여기 data-bs-target 랑 모달의 id 맞춰줘야함 -->
  		전기 사용량 통계
	</button>
	<!-- Modal -->
	<div class="modal fade" id="chart" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
	  <div class="modal-dialog modal-xl">
	    <div class="modal-content">
	      <div class="modal-header">
	        <h1 class="modal-title fs-5" id="exampleModalLabel">전기 사용량 통계</h1>
	        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
	      </div>
	      <!-- 모달 내부의 body -->
	      <div class="modal-body">
	      <div id="modal_sdchart" style="width: 100%; height: 600px;"></div><!-- 여기 아이디 값 구글차트에 맞춰줘야함 -->
			</div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
	      </div>
	    </div>
	  </div>
	</div>


<script type="text/javascript">

$('#chart').on('shown.bs.modal', function () {
 	var selectedValue = document.getElementById("ChartSelect").value;
	alert(selectedValue);

	 
	// Google 차트 로드
	  google.charts.load('current', {packages: ['corechart', 'bar']});
	  google.charts.setOnLoadCallback(drawBasic);

	  // 차트를 그리는 함수
	  function drawBasic() {
		  if(selectedValue === "all"){
		    var data = google.visualization.arrayToDataTable([
		      ['City', '2022 전기에너지'],
	    	  <c:forEach items="${sdChartList}" var="sdChart">
	     		 ['${sdChart.sd_nm}', ${sdChart.totaluse}],
	     	  </c:forEach>
	    	]);
		  } else{
			  var data = google.visualization.arrayToDataTable([
				  ['City', '2022 전기에너지'],
				  ['도시', 40000],
				  ['도시', 40000],
				  ['도시', 40000]
			  ]);
		  }
	    var options = {
	      title: '시도별 전기에너지 사용량',
	      chartArea: {width: '50%'},
	      hAxis: {
	        title: '총사용량',
	        minValue: 0
	      },
	      vAxis: {
	        title: '도시'
	      }
	    };

	    // 모달 내부의 차트 div를 찾아서 차트를 생성
	    var chart = new google.visualization.BarChart(document.getElementById('modal_sdchart'));

	    chart.draw(data, options);
	  }
});


</script>

</body>
</html>