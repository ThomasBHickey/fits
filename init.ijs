NB. JFits/init.ijs

NB. The Header data is in 80 byte rows.  8 bytes of label, possibly followed by '='
getHdrVal =: 4 : '{.0". 9}. ({.I.(8{."1 x)-:"1 ]8{.y){x'NB. Pad label, find 1st, make rest numeric

splitFitsData =: 3 : 0 NB. y is raw fits file contents
    	data80=. (((#y)%80), 80) $ y
	endPos =. {.I. (8{."1 data80)-:"1 ]8{.'END'
	numHdrBlocks =. >:<.endPos%36        NB. File organized in 2880 byte blocks
	hdata  =. (>:endPos) {. data80
	rdata  =. (numHdrBlocks*36*80) }. y  NB. raw Image data follows hdr blocks
	fields =. ;: 'BITPIX NAXIS NAXIS1 NAXIS2 NAXIS3'
     (fields) =. hdata&getHdrVal&.> fields
	NAXIS3 =. NAXIS3 >. 1
	select. BITPIX
	  case. _32 do. adata =. (NAXIS3,NAXIS2,NAXIS1)$ |. _1 fc |. rdata
	  case. _64 do. adata =. (NAXIS3,NAXIS2,NAXIS1)$ |. _2 fc |. rdata
	  case. 16  do. adata =. (NAXIS3,NAXIS2,NAXIS1)$ |. _1 ic |. rdata
	  case. 32  do. adata =. (NAXIS3,NAXIS2,NAXIS1)$ |. _2 ic |. rdata
	end.
	hdata;adata
)

scaleT2D =: 4 : 0  NB. (minCut, maxCut) scaleT2D 2Ddata
	ry =. ,y     NB. easier raveled
	nanPos =. 128!:5 ry   
	numData =. (I. -. nanPos) { ry 
	srtData =. /:~ numData
     'minWanted maxWanted' =: (<.x*#srtData){srtData
	ry =. minWanted (I. nanPos) } ry  NB. replace NAN's
	ry =. minWanted (I. (ry<minWanted)) } ry
	ry =. maxWanted (I. (ry>maxWanted)) } ry
	ry =. ry - minWanted NB. makes minWanted at 0
	scale =. 255% maxWanted-minWanted
	|.($y) $ <. ry*scale  NB. Transposed 2D array
)

sample2D =: 4 : 0  NB. samplefreq sample2D image
	'a0 a1' =. $y
	(<.(x*i.>.a0%x)) { (<.(x*i.>.a1%x)){"1 y
)
