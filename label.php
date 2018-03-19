<?php
$uploadDir = "upload";
$processedDir = "processed";
$show = array();

$label_id = 'null';
if(isset($_GET['label_id'])){
    $label_id = $_GET["label_id"];
    $carrier = label_to_carrier($label_id);
    $runPath = 'run.'.$carrier.'.sh';
}
$client = '';
if(isset($_GET['client']) && $_GET['client']){
    $client = $_GET['client'];
}
$itm = '';
if(isset($_GET['itm']) && $_GET['itm']){
    $itm = $_GET['itm'];
}

function label_to_carrier($label_id){
    $re = array(
        'chronopost'=> '/^[PX]\w+\d+\w{2}$/',
        'dhl'       => '/^\d{10}$/',
        'laPoste'   => '/^1L\d{11}$/',
        'colissimo' => '/^[C]\w+\d+\w{2}|[2-9]\w\d{11}$/'
    );
    foreach($re as $k=>$v){
        if(preg_match($v,$label_id)){
            return $k;
        }
    }
}

exec("./".$runPath);
$re = $processedDir.'/*';
if($label_id){
    $re.= $label_id.'*';
}
$dirs = array_filter(glob($re), 'is_dir');
$lastDir = $dirs[count($dirs)-1];
$count = count($dirs);

if(!$count){
    $show['form'] = true;
    $show['fail'] = true;
}else{
    $show[$client] = true;
    if($client != 'retrait'){
        $show['label-'.$carrier] = true;
        if($carrier == 'colissimo'){
            $show['proof-'.$carrier] = true;
        }
    }
    if($client != 'expedition'){
        $show['proof-'.$carrier] = true;
        $show['blanks-'.$carrier] = true;
    }
    $show['item-'.$carrier] = true;
}

function page_title($label_id){
    return date('Ymd').'T'.date('Hi').' '.$label_id;
}

function print_visibility($show){
    $str = '';
    foreach($show as $k=>$v){
        if($v){
            $str.='.'.$k.'{display:block;}';
        }
    }
    return $str;
}

function page_break($show){
    $str='.item-'.$carrier.'{page-break-';
    if(array_key_exists('expedition',$show)){
        $str.= 'after';
    }
    else{
        $str.= 'before';
    }
    $str.=':always;}';
    return $str;
}

function print_js($show){
    if($show['form'] || $show['fail']){
        $str = '';
    }
    else{
        $str = '
<script type="text/javascript">
    window.print();
</script>
        ';
    }
    return $str;
}
?>

<!doctype html>
<meta charset="utf-8">
<html>  
<head>  
<link rel="stylesheet" type="text/css" href="label.css">
<title>label <?php echo page_title($label_id) ?></title>
<style>
<?php
echo print_visibility($show);
echo page_break($show);
?>
</style>
</head>  
<body>  

<div class="form">
    <form action="<?php echo $_SERVER['REQUEST_URI']?>">
        <label for="label_id">Référence du bon de transport à imprimer :</label>
        <input id="label_id" name="label_id" value="" type="text"></input>

        <label for="itm">Références d'objets à imprimer :</label>
        <input id="itm" name="itm" value="" type="text"></input>
        
        <label for="expedition">Expedition</label>
        <input id="expedition" name="client" value="expedition" type="radio" checked></input>

        <label for="retrait">Retrait client</label>
        <input id="retrait" name="client" value="retrait" type="radio"></input>

        <label for="depot">Depot client</label>
        <input id="depot" name="client" value="depot" type="radio"></input>

        <label for="address">Adresse de livraison :</label>
        <textarea id="address" name="address" rows="6" cols="40"></textarea>

        <hr>

        <input type="submit"></input>
    </form>
</div>

<div class="label label-chronopost label-colissimo">
    <img class="chronopost" src="<?php echo $lastDir; ?>/tracking.png"></img>
    <svg class="blanks-chronopost">
        <rect style="fill:white;" width="4.5cm" height="0.7cm"  x="0.30cm" y="6.35cm" />
        <rect style="fill:white;" width="3.05cm" height="3.05cm"    x="7.05cm" y="4.35cm" />
        <rect style="fill:white;" width="10cm" height="5.65cm"  x="0.10cm" y="7.50cm" />
        <line x1="0" y1="0" x2="10.2cm" y2="13.29cm" style="stroke:rgb(50,50,50);stroke-width:1" />
        <line x1="0" y1="13.29cm" x2="10.2cm" y2="0" style="stroke:rgb(50,50,50);stroke-width:1" />
    </svg>
</div>

<div class="label label-dhl">
    <img class="dhl" src="<?php echo $lastDir; ?>/tracking.png"></img>
    <img class="dhl" src="<?php echo $lastDir; ?>/tracking2.png"></img>
</div>

<div class="item-chronopost item-colissimo">
    <span class="retrait">Preuve de retrait par le client de :</span>
    <span class="depot">Preuve de dépôt par le client de : </span>
    <?php echo $itm; ?>
</div>

<div class="label-laPoste">  
ok
    <div id="from">
        <div class="title">From / Adresse d\'expédition :</div>
        <div class="address">
            Geekadomicile.com<br/>62 avenue des Etats-Unis<br/>78000 Versailles<br/>YVELINES<br/>France<br/>+33977555556<br/>laPoste@geekadomicile.com
        </div>
        <div id="itemName"><?php echo $itm; ?>
        </div>
        <svg>
            <line x1="0" y1="0" x2="7cm" y2="3.1cm" style="stroke:rgb(50,50,50);stroke-width:1" />
            <line x1="0" y1="3.1cm" x2="7cm" y2="0" style="stroke:rgb(50,50,50);stroke-width:1" />
        </svg>
    </div>
    <div id="stamp">
    <img src="<?php echo $lastDir; ?>/stamp.png"></img>
        <div class="logo"></div>
    </div>
    <div id="tracking">
        <img src="<?php echo $lastDir ?>/tracking.png"></img>
    </div>
    <div id="to">
        <div class="title">To / Adresse de livraison :</div>
        <pre class="address"><textarea id="address" rows="6" cols="40"><?php echo $address ?></textarea>
        </pre>
    </div>
</div>  

<div class="proof-chronopost proof-colissimo">
    <img src="<?php echo $lastDir; ?>/proof.png"></img>
</div>

<div class="fail">
    Je n'ai pas trouvé d'étiquette :(
</div>

</body>
<?php
echo print_js($show);
?>
</html>
