skillIds = [];
storedSkills = [];

$(function(){
    if (gon.dynamic_skills_insertion_enabled == true) { registerSkillsHandker(); }

    $('body').on('change', '#skills-container select', function(){
        setSkills($(this));
    });
    $.each($('#skills-container select'), function() {
        setSkills($(this));
    })

    $('#skills-container').on('cocoon:after-insert', function(e, insertedItem) {
        setSkills($(insertedItem).find('select'));
    });

    // Sorting

    $('#skills-container').sortable({
        placeholder: "ui-state-highlight",
        //start: (event, ui) => {$('.slide-up-or-down-sort').slideUp()}//,
        stop: (event, ui) => {$('.session_session_skills_position').each((index, div) => $(div).children('input').each((i, ch) => $(ch).val(index + 1)))}
    })
});

function registerSkillsHandker(){
    $('#session_project_role_id').change(function(){
        projectRoleId = $(this).find('option:selected').val();
        skillIds = gon.project_roles_skills.filter(x => x.id == projectRoleId)[0].skills.map(x => x.id);
        // storedSkills = gon.stored_session_skills;
        clearAllSkills();
        $.each(skillIds, function(i, elem){
            addSkill(elem);
        });
    });

    $('#skills-container').on('cocoon:after-insert', function(e, insertedItem) {
        id = skillIds.pop(0);
        if (id) { insertedItem.find('select:last')[0].value = id; }
        setSkills($(insertedItem).find('select'));
    });
}

clearAllSkills = function(){
    $('.skill-fields').each(function(){
        // current_id = $(this).find('select:last')[0].value
        //console.log(skillIds.includes(parseInt(current_id)));
        // if (skillIds.includes(parseInt(current_id))){
        //     //console.log('filtered!');
        //     skillIds = skillIds.filter(function(elem){
        //         return elem != parseInt(current_id);
        //     });
        // } else {
        //     //console.log('deleted!');
        //     $(this).find('.remove_fields')[0].click()
        // }
        $(this).find('.remove_fields')[0].click();
    })
}

function addSkill(id){
    // console.log('----------------');
    // console.log(storedSkills);
    // console.log(id);
    // console.log(storedSkills.map(x => x.skill_id).includes(parseInt(id)));
    // if (!storedSkills.map(x => x.skill_id).includes(parseInt(id))) {
    //     $('#add-skills').click();
    // } else {
    //     console.log('repaired!')
    //     repairSkill(storedSkills.filter(x => x.skill_id == parseInt(id))[0])
    // }
    $('#add-skills').click();

    //$('#skills-container').find('select:last')[0].value = id;
}

// repairSkill = function(skill){
//     $('.skill-fields').each(function(){
//         currentId = parseInt($(this).find('select:last')[0].value);
//         console.log('*******');
//         console.log(currentId);
//         console.log($(this).find('[id*="_destroy"]'));
//         if (currentId == skill.skill_id) {
//             $(this).removeAttr("style");
//             $(this).find('input[name*="_destroy"]')[0].value = 0;
//         }
//     })
// }

function setSkills(that){
    container = that.closest('.skill-fields')
    skillId = parseInt(that[0].value);
    currentSkillElem = container.find('.skill-indicators');
    indicators = gon.skills.filter(x => x.id == skillId)[0].indicators.map(x => x.name);
    insertList = '';
    $.each(indicators, function (i, elem) {
        insertList += '<li>' + elem + '</li>';
    });
    currentSkillElem.html(insertList);
};


// SHOW

$(function() {
    if (gon.summary_chart) {
        var ctx = document.getElementById('common-skill-chart').getContext('2d');
        var chart = new Chart(ctx, {
            type: 'radar',
            data:{
                labels: gon.summary_chart.labels,
                datasets: gon.summary_chart.datasets
            },
            options: {
                scale: {
                    ticks: {
                        beginAtZero: true,
                        max: 6
                    }
                }
            }
        })
    }
    if (gon.skill_charts) {
        skillIds = Object.keys(gon.skill_charts);
        skillIds.forEach(x => {
            skill = gon.skill_charts[x];
            var ctx = document.getElementById('skill_chart_'+x).getContext('2d');
            var tmpChart = new Chart(ctx, {
                type: 'bar',
                data:{
                    labels: gon.skill_charts[x].lables,
                    datasets: gon.skill_charts[x].datasets
                },
                options: {
                    scales: {
                        xAxes: [{
                            ticks: {
                                minRotation: 45,
                                maxRotation: 60,
                                fontSize: 10
                            }
                        }],
                        yAxes: [{
                            ticks: {
                                min: 0,
                                max: 6
                            }
                        }]
                    }
                }
            });
        });
    }
});