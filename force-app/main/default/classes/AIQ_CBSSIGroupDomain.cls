public with sharing class AIQ_CBSSIGroupDomain {
    public static final Id LINE_DRAFT_RECORD_TYPE_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
        .get('Draft')
        .getRecordTypeId();
    public static final Id LINE_ACTIVE_RECORD_TYPE_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
        .get('Active')
        .getRecordTypeId();
    public static final Id LINE_INACTIVE_RECORD_TYPE_ID = Schema.SObjectType.zpl__ContractLineItem__c.getRecordTypeInfosByDeveloperName()
        .get('Inactive')
        .getRecordTypeId();
    @TestVisible
    private static final String LINE_GROUP_KEY_MISMATCH_ERROR = 'The line does not belong to this group';
    private List<AIQ_CBSSILine> cbssiLines;
    private String cbssiKey;
    private Boolean isGroupSorted = false;

    private AIQ_CBSSIGroupDomain() {
    }

    public AIQ_CBSSIGroupDomain(String cbssiKey) {
        this.cbssiLines = new List<AIQ_CBSSILine>();
        this.cbssiKey = cbssiKey;
    }

    /**
     * @description getLine used to return the current line out of the group
     * @param  currentLine current line being requested
     * @return             current line retrieved out of the group
     */
    public zpl__ContractLineItem__c getLine(zpl__ContractLineItem__c currentLine) {
        Integer currentLineIndex = getCurrentLineIndex(currentLine);
        if (currentLineIndex == -1) {
            return null;
        }
        return this.cbssiLines.get(currentLineIndex)?.line;
    }

    /**
     * @description getEffectiveLine finds the line being effective
     * @return             returns the line being effective. If the effective line is not found, returns null
     */
    public zpl__ContractLineItem__c getEffectiveLine() {
        for (AIQ_CBSSILine cbssiLine : getGroupLines()) {
            if (cbssiLine.line.RecordTypeId == LINE_ACTIVE_RECORD_TYPE_ID && cbssiLine.line.SupersededDate__c == null) {
                return cbssiLine.line;
            }
        }
        return null;
    }

    /**
     * @description getNextActiveLine finds the next active line to activate against the one being passed as input
     * @param  currentLine the line being changed
     * @return             returns the next line to activate. If next line is not found, returns null
     */
    public zpl__ContractLineItem__c getNextActiveLine(zpl__ContractLineItem__c currentLine) {
        Integer currentLineIndex = getCurrentLineIndex(currentLine);
        if (currentLineIndex <= 0) {
            return null;
        }

        for (Integer i = currentLineIndex - 1; i >= 0; i--) {
            AIQ_CBSSILine nextCbssiLine = getGroupLines().get(i);
            if (nextCbssiLine.line.RecordTypeId == LINE_ACTIVE_RECORD_TYPE_ID && nextCbssiLine.line.SupersededDate__c == null) {
                return nextCbssiLine.line;
            }
        }

        return null;
    }

    /**
     * @description getPriorLine finds the prior active line against the one being passed as input within the given time horizon interval.
     * Prior line is needed to fill in 'prior' fields and identify the price decrease
     * @param  currentLine the line being changed
     * @param  horizonDate the data horizon in the past to look for prior line
     * @return             returns the prior active line. If prior line is not found, returns null
     */
    public zpl__ContractLineItem__c getPriorLine(zpl__ContractLineItem__c currentLine, Date horizonDate) {
        Integer currentLineIndex = getCurrentLineIndex(currentLine);
        if (currentLineIndex == -1) {
            return null;
        }
        for (Integer i = currentLineIndex + 1; i < getGroupLines().size(); i++) {
            AIQ_CBSSILine priorCbssiLine = getGroupLines().get(i);
            if (priorCbssiLine.line.RecordTypeId != LINE_ACTIVE_RECORD_TYPE_ID) {
                continue;
            }
            Boolean horizonValidation = horizonDate == null ? true : priorCbssiLine.line.zpl__EffectiveDate__c > horizonDate;
            if (horizonValidation) {
                return priorCbssiLine.line;
            }
        }

        return null;
    }

    /**
     * @description getPriorLines finds the prior active and not superseded line(s) against the one being passed as input.
     * This method is used to find line(s) that can be superseded
     * @param  currentLine the line being changed
     * @return             returns True if there are lines to supersede and False if no
     */
    public Boolean getSupersededLines(zpl__ContractLineItem__c currentLine) {
        Integer currentLineIndex = getCurrentLineIndex(currentLine);
        if (currentLineIndex == -1) {
            return false;
        }
        AIQ_CBSSILine cbssiLineCurrent = this.cbssiLines.get(currentLineIndex);
        if(cbssiLineCurrent.line.zpl__EffectiveDate__c > Date.today()) {
            return false;
        }

        List<AIQ_CBSSILine> priorLines = new List<AIQ_CBSSILine>();
        for (Integer i = currentLineIndex + 1; i < getGroupLines().size(); i++) {
            AIQ_CBSSILine priorCbssiLine = getGroupLines().get(i);
            if (priorCbssiLine.line.RecordTypeId != LINE_ACTIVE_RECORD_TYPE_ID) {
                continue;
            }
            if (priorCbssiLine.line.isCurrent__c || priorCbssiLine.line.SupersededDate__c == null) {
                priorLines.add(this.supersedeLine(priorCbssiLine));
            }
        }
        return ! priorLines.isEmpty();
    }

    /**
     * @description getDuplicates finds the cbssi line that has different line key but the same effective date within the cbssi group
     * This method is used to find line(s) that are duplicated and have to be deleted
     * @param  currentLine the line being changed
     * @return             returns False if there are no duplicates otherwise returns True
     */
    public Boolean getDuplicates(zpl__ContractLineItem__c currentLine) {
        Integer currentLineIndex = getCurrentLineIndex(currentLine);
        if (currentLineIndex == -1) {
            return false;
        }
        AIQ_CBSSILine cbssiLineCurrent = this.cbssiLines.get(currentLineIndex);

        if (!cbssiLineCurrent.line.isCurrent__c && cbssiLineCurrent.line.SupersededDate__c != null) {
            return false;
        }

        List<AIQ_CBSSILine> duplicates = new List<AIQ_CBSSILine>();
        for (AIQ_CBSSILine cbssiLine : getGroupLines()) {
            if (
                !System.equals(cbssiLineCurrent, cbssiLine) &&
                cbssiLineCurrent.line.zpl__EffectiveDate__c == cbssiLine.line.zpl__EffectiveDate__c
            ) {
                duplicates.add(this.inactivateDuplicate(cbssiLine));
            }
        }
        return ! duplicates.isEmpty();
    }

    /**
     * @description realign used to update the targeted lines of the CBSSI group
     * @param  currentLine the line triggering the realignment
     * @return             returns the instance of this group
     */
    public AIQ_CBSSIGroupDomain realign(zpl__ContractLineItem__c currentLine) {
        AIQco_Precondition.checkNotNull(currentLine, 'Current line is null');
        Integer currentLineIndex = getCurrentLineIndex(currentLine);
        AIQ_CBSSILine cbssiLineCurrent;
        if (currentLineIndex != -1) {
            cbssiLineCurrent = this.cbssiLines.get(currentLineIndex);
        }
        this.getDuplicates(cbssiLineCurrent.line);
        this.getSupersededLines(cbssiLineCurrent.line);
        return this;
    }

    /**
     * @description getChangedLines used to return the lines being modified
     * @return   returns the list of the changes Contract Line Items
     */
    public List<zpl__ContractLineItem__c> getChangedLines() {
        List<zpl__ContractLineItem__c> changedLines = new List<zpl__ContractLineItem__c>();
        for (AIQ_CBSSILine cbssiLine : cbssiLines) {
            if (cbssiLine.isChanged) {
                changedLines.add(cbssiLine.line);
            }
        }
        return changedLines;
    }

    /**
     * @description getChangedLines used to return the lines being modified and not original (not started the transaction)
     * @return   returns the list of the changes Contract Line Items that did not originate the execution
     */
    public List<zpl__ContractLineItem__c> getChangedLinesWithoutOriginal() {
        List<zpl__ContractLineItem__c> changedLines = new List<zpl__ContractLineItem__c>();
        for (AIQ_CBSSILine cbssiLine : cbssiLines) {
            if (cbssiLine.isChanged && cbssiLine.isOriginal != true) {
                changedLines.add(cbssiLine.line);
            }
        }
        return changedLines;
    }

    /**
     * @description inactivateDuplicate compares two different lines by Effective Date. If Effective Date matches the second line is getting inactivated.
     * @param  cbssiLineCurrent  current line
     * @param  cbssiLineCompared secondary line that may get inactivated
     * @return                   returns true when the second line is inactivated, otherwise returns false
     *
     */
    private AIQ_CBSSILine inactivateDuplicate(AIQ_CBSSILine cbssiDuplicate) {
        cbssiDuplicate.line.RecordTypeId = LINE_INACTIVE_RECORD_TYPE_ID;
        cbssiDuplicate.line.zpl__Status__c = 'Deleted';
        return supersedeLine(cbssiDuplicate);
    }

    private AIQ_CBSSILine supersedeLine(AIQ_CBSSILine cbssiLine) {
        cbssiLine.line.isCurrent__c = false;
        if (cbssiLine.line.SupersededDate__c == null) {
            cbssiLine.line.SupersededDate__c = System.now();
        }
        if (cbssiLine.line.Inactivated_By__c == null) {
            cbssiLine.line.Inactivated_By__c = UserInfo.getUserId();
        }
        if (cbssiLine.line.Inactivated_Date__c == null) {
            cbssiLine.line.Inactivated_Date__c = System.now();
        }
        cbssiLine.isChanged = true;

        return cbssiLine;
    }

    /**
     * @description addLines used to add lines to the group eliminating duplicates. The incoming line version is kept
     * @param  lines the list of Contract Line Item objects being added
     * @return      returns AIQ_CBSSIGroupDomain object instance
     */
    public AIQ_CBSSIGroupDomain addLines(List<zpl__ContractLineItem__c> lines, Boolean isOriginal) {
        AIQco_Precondition.checkNotNull(lines, 'List of lines is null');
        AIQco_Precondition.checkArgument(lines.isEmpty(), 'List of lines is empty');

        for (zpl__ContractLineItem__c line : lines) {
            addLine(line, isOriginal);
        }

        return this;
    }

    /**
     * @description addLine used to add lines to the group eliminating duplicates. The incoming line version is kept
     * @param  line Contract Line Item object being added
     * @return      returns AIQ_CBSSIGroupDomain object instance
     */
    public AIQ_CBSSIGroupDomain addLine(zpl__ContractLineItem__c line, Boolean isOriginal) {
        AIQco_Precondition.checkNotNull(line, 'line is null');
        AIQco_Precondition.checkArgument(line.CBSSItemGroupingKey__c != this.cbssiKey, LINE_GROUP_KEY_MISMATCH_ERROR);

        AIQ_CBSSILine cbssiLine = new AIQ_CBSSILine(line);
        if (this.cbssiLines.contains(cbssiLine)) {
            return this;
        }
        cbssiLine.isOriginal = isOriginal;
        this.cbssiLines.add(cbssiLine);
        this.isGroupSorted = false;

        return this;
    }

    /**
     * @description used to return the sorted list of CBSSI lines
     * @return   returns list of AIQ_CBSSILine objects
     */
    public List<AIQ_CBSSILine> getGroupLines() {
        if (!this.isGroupSorted) {
            cbssiLines.sort();
            this.isGroupSorted = true;
        }
        return cbssiLines;
    }

    private Integer getCurrentLineIndex(zpl__ContractLineItem__c currentLine) {
        return getGroupLines().indexOf(new AIQ_CBSSILine(currentLine.zpl__ContractLineItemId__c));
    }

    private Integer hashCode() {
        return new AIQco_HashCodeBuilder().append(this.cbssiKey).toHashCode();
    }

    private Boolean equals(Object outerObj) {
        if (outerObj != null && outerObj instanceof AIQ_CBSSIGroupDomain) {
            AIQ_CBSSIGroupDomain outerGroup = (AIQ_CBSSIGroupDomain) outerObj;
            return this.cbssiKey == outerGroup.cbssiKey;
        }
        return false;
    }
}