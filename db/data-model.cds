using {
    Currency,
    managed,
    sap,
    cuid
} from '@sap/cds/common';

extend sap.common.Currencies with {
    numcode  : Integer;
    exponent : Integer; //> e.g. 2 --> 1 Dollar = 10^2 Cent
    minor    : String; //> e.g. 'Cent'
}

context teched.common {
    type BusinessKey : String(10);
    type SDate : DateTime;

    @assert.range : true // Valida o conteudo
    type StatusT : String(1) enum {
        New        = 'N';
        Incomplete = 'I';
        Approved   = 'A';
        Rejected   = 'R';
        Confirmed  = 'C';
        Saved      = 'S';
        Delivered  = 'D';
        Cancelled  = 'X';
    }

    type AmountT : Decimal(15, 2)@(
        Semantics.amount.currencyCode : 'CURRENCY_code',
        sap.unit                      : 'CURRENCY_code'
    );

    abstract entity Amount { // abstract nao vai criar tabela ou view. apenas declarar estrutura
        currency    : Currency;
        grossAmount : AmountT;
        netAmount   : AmountT;
        taxAmount   : AmountT;
    }

    annotate Amount with { // anotate incluir traducao na tabela
        grossAmount @(title : '{i18n>grossAmount}');
        netAmount   @(title : '{i18n>netAmount}');
        taxAmount   @(title : '{i18n>taxAmount}');
    }

    type QuantityT : Decimal(13, 3)@(title : '{i18n>quantity}'); // colocar traducao para campos
    type UnitT : String(3)@title : '{i18n>quantityUnit}';

    abstract entity Quantity {
        quantity     : QuantityT;
        quantityUnit : UnitT;
    }
}

context teched.PurchaseOrder {
    entity Headers : managed, cuid, teched.common.Amount {
        @cascade : {all} //	Allows to cascade insert, update, and delete operations over selected associations
        
        item            : Composition of many Items // associacao com Item
                              on item.poHeader = $self;
                              
        noteId          : teched.common.BusinessKey null;
        partner         : UUID;
        lifecycleStatus : teched.common.StatusT default 'N';
        approvalStatus  : teched.common.StatusT;
        confirmStatus   : teched.common.StatusT;
        orderingStatus  : teched.common.StatusT;
        invoicingStatus : teched.common.StatusT;
    }

    entity Items : cuid, teched.common.Amount, teched.common.Quantity {
        poHeader     : Association to Headers; // associa com cabecalho
        product      : teched.common.BusinessKey;
        noteId       : teched.common.BusinessKey null;
        deliveryDate : teched.common.SDate;
    }
}