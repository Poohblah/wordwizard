module.exports = (grunt)->
	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		files:
			src: 'src'
			build: 'build'

		clean:
			build:
				src: ['<%= files.build %>']

		copy:
			build:
				files: [
					expand: true
					cwd: '<%= files.src %>'
					src: ['**/*.html']
					dest: '<%= files.build %>'
					]

		coffee:
			build:
				files: [
					expand: true
					cwd: '<%= files.src %>'
					src: ['**/*.coffee', '!**/*.spec.coffee']
					dest: '<%= files.build %>'
					ext: '.js'
				]

		less:
			build:
				files:
					'<%= files.build %>/css/style.css':
						'<%= files.src %>/css/style.less'

		watch:
			coffee:
				files: ['<%= files.src %>/js/**/*.coffee',
					'!<%= files.src %>/js/**/*.spec.coffee']
				tasks: [ 'newer:coffee' ]
			less:
				files: ['<%= files.src %>/css/**/*.less']
				tasks: [ 'less' ]
			html:
				files: ['<%= files.src %>/html/**/*.html']
				tasks: [ 'newer:html' ]

	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-less'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-newer'

	grunt.registerTask 'build', [
		'clean',
	 	'copy',
	 	'less',
		'coffee'
		]
	grunt.registerTask 'default', ['build']
